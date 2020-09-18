import {
  Resolver,
  Query,
  Mutation,
  Arg,
  Ctx,
  Authorized,
  ID
} from 'type-graphql';
import Account from '../entities/account.entity';
import jwt from 'jsonwebtoken';
import { JWT_PUBLIC_KEY, JWT_PRIVATE_KEY } from '../config';
import bcrypt from 'bcryptjs';
import { Context } from 'koa';
import {
  AccountInput,
  UpdateAccountInput,
  LogInInput
} from '../input/account.input';
import { verifyRecaptcha } from '../utils/recaptcha';
import Token from '../entities/tokens.entity';
import { addHours } from 'date-fns';
import { sendMail } from '../utils/sendMail';
import { GraphQLUpload } from 'graphql-upload';
import { createWriteStream } from 'fs';
import { Stream } from 'stream';

@Resolver()
export class AccountResolver {
  @Authorized()
  @Query(() => [Account])
  accounts(): Promise<Account[]> {
    return Account.find();
  }

  @Authorized()
  @Query(() => Account)
  async account(@Arg('id', () => ID) id: number): Promise<Account | boolean> {
    return (await Account.findOne({ where: { id } })) || false;
  }

  @Mutation(() => Account)
  async createAccount(
    @Arg('account') { password, email, captchaToken, ...rest }: AccountInput
  ): Promise<Account> {
    const passwordHash = await bcrypt.hash(password, 12);
    const isHuman = await verifyRecaptcha(captchaToken);

    if (!isHuman) throw new Error(`Recaptcha failed!`);

    const account = Account.create({
      email,
      ...rest,
      passwordHash
    });

    const token = Math.random().toString(36).substr(2);

    const savedToken = Token.create({
      token
    });

    await savedToken.save();

    account.tokens = [savedToken];

    await account.save();

    await sendMail(token, 'VERIFY', email);
    return account;
  }

  @Authorized()
  @Mutation(() => Account)
  async updateAccount(
    @Ctx() ctx: Context,
    @Arg('account') { password, ...rest }: UpdateAccountInput
  ): Promise<Account> {
    const account = await Account.findOne({
      where: { id: ctx.state.user.id }
    });

    if (!account) throw new Error(`Account doesn't exist`);
    const passwordHash = password && (await bcrypt.hash(password, 10));

    Object.assign(account, { ...rest, passwordHash });

    await account.save();
    return account;
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteAccount(@Ctx() ctx: Context): Promise<boolean> {
    const account = await Account.findOne({
      where: { id: ctx.state.user.id }
    });
    if (!account) throw new Error(`Account doesn't exist`);

    await account.remove();
    return true;
  }

  @Query(() => Boolean)
  async logIn(
    @Ctx() ctx: Context,
    @Arg('account') { username, password }: LogInInput
  ): Promise<boolean> {
    const account = await Account.findOne({ where: { username } });
    if (!account) return false;

    const correctPassword = await bcrypt.compare(
      password,
      account.passwordHash
    );

    if (correctPassword) {
      ctx.cookies.set(
        JWT_PUBLIC_KEY,
        jwt.sign({ id: account.id }, JWT_PRIVATE_KEY, { expiresIn: '2d' }),
        { secure: false, httpOnly: true }
      );

      return true;
    }
    return false;
  }

  @Query(() => Boolean)
  @Authorized()
  async logOut(@Ctx() ctx: Context): Promise<boolean> {
    ctx.cookies.set(JWT_PUBLIC_KEY);
    return true;
  }

  @Authorized()
  @Query(() => Account)
  async currentAccount(@Ctx() ctx: Context): Promise<Account | boolean> {
    return (
      (await Account.findOne({ where: { id: ctx.state.user.id } })) || false
    );
  }

  @Authorized()
  @Query(() => Boolean)
  async requestPasswordReset(
    @Arg('email', () => String) email: string
  ): Promise<boolean> {
    const account = await Account.findOne({ where: { email } });

    if (!account) throw new Error(`Account doesn't exist with that email.`);

    const token = Math.random().toString(36).substr(2);
    const savedToken = Token.create({
      token
    });

    await savedToken.save();
    account.tokens = [savedToken];
    account.save();

    sendMail(token, 'RESET', email);

    return true;
  }

  @Mutation(() => Boolean)
  async resetPassword(
    @Arg('token', () => String) token: string,
    @Arg('password', () => String) password: string
  ): Promise<boolean> {
    const tokenAccount = await Token.findOne({
      where: { token },
      relations: ['account']
    });

    if (!tokenAccount) throw new Error(`The token doesn't exist.`);

    if (tokenAccount.isUsed)
      throw new Error(`The token has already been used.`);

    if (addHours(tokenAccount.createdDate, 24) > new Date())
      throw new Error(`The token has expired!.`);

    const accountData = await tokenAccount.account;
    const account = await Account.findOne(accountData.id);

    if (!account) throw new Error(`Account doesn't exist`);

    const passwordHash = await bcrypt.hash(password, 12);

    account.passwordHash = passwordHash;
    tokenAccount.isUsed = true;

    account.save();
    tokenAccount.save();

    return true;
  }

  @Mutation(() => Boolean)
  async verifyAccount(
    @Arg('token', () => String) token: string
  ): Promise<boolean> {
    const tokenAccount = await Token.findOne({
      where: { token },
      relations: ['account']
    });

    if (!tokenAccount) throw new Error(`Token doesn't exist`);

    if (addHours(tokenAccount.createdDate, 24) > new Date())
      throw new Error(`The token has expired!.`);

    if (tokenAccount.isUsed) return false;

    const accountData = await tokenAccount.account;
    const account = await Account.findOne(accountData.id);

    if (!account) throw new Error(`Account doesn't exist`);

    account.isVerified = true;
    tokenAccount.isUsed = true;

    account.save();
    tokenAccount.save();

    return true;
  }

  @Mutation(() => Boolean)
  async uploadProfilePicture(
    @Arg('picture', () => GraphQLUpload)
    { createReadStream, filename }: Upload
  ): Promise<boolean> {
    createReadStream;
    // eslint-disable-next-line no-async-promise-executor
    return new Promise(async (resolve, reject) =>
      createReadStream()
        .pipe(createWriteStream(__dirname + `/../../uploads/${filename}`))
        .on('finish', () => resolve(true))
        .on('error', () => reject(false))
    );
  }
}

export interface Upload {
  filename: string;
  mimetype: string;
  encoding: string;
  createReadStream: () => Stream;
}
