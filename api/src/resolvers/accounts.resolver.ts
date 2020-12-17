import {
  Resolver,
  Query,
  Mutation,
  Arg,
  Ctx,
  Authorized,
  ID,
  ObjectType,
  Field,
  registerEnumType
} from 'type-graphql';
import Account from '../entities/account.entity';
import jwt from 'jsonwebtoken';
import config from '../config';
import bcrypt from 'bcryptjs';
import { Context } from 'koa';
import {
  AccountInput,
  UpdateAccountInput,
  LogInInput
} from '../input/account.input';
import { verifyRecaptcha } from '../utils/verifyRecaptcha';
import { sendMail } from '../utils/sendMail';
import { GraphQLUpload } from 'graphql-upload';
import { Stream } from 'stream';
import bucketUploader from '../utils/bucketUploader';

@Resolver()
export class AccountResolver {
  @Authorized()
  @Query(() => [Account])
  accounts(): Promise<Account[]> {
    return Account.find();
  }

  @Authorized('ADMIN')
  @Query(() => Account)
  async account(@Arg('id', () => ID) id: number): Promise<Account | boolean> {
    return (await Account.findOne({ where: { id } })) || false;
  }

  @Mutation(() => Account)
  async createAccount(
    @Ctx() { redis }: Context,
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

    await redis.set(token, email, 'ex', 1000 * 60 * 60 * 24 * 3);
    await account.save();

    await sendMail(token, 'VERIFY', email);
    return account;
  }

  @Query(() => Boolean)
  async requestAccountVerification(
    @Arg('username') username: string,
    @Ctx() { redis }: Context
  ): Promise<boolean> {
    const account = await Account.findOne({ where: { username } });

    if (!account) throw Error("The account doesn't exist");

    const token = Math.random().toString(36).substr(2);

    await redis.set(token, account.email, 'ex', 1000 * 60 * 60 * 24 * 3);
    await sendMail(token, 'VERIFY', account.email);

    return true;
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

  @Authorized('ADMIN')
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

  @Query(() => LoginResult)
  async logIn(
    @Ctx() ctx: Context,
    @Arg('account') { username, password }: LogInInput
  ): Promise<LoginResult> {
    const account = await Account.findOne({ where: { username } });
    if (!account) return LoginResult.INEXISTENT_ACCOUNT;

    const correctPassword = await bcrypt.compare(
      password,
      account.passwordHash
    );

    if (correctPassword) {
      if (!account.isVerified) return LoginResult.UNVERIFIED_ACCOUNT;

      ctx.cookies.set(
        config.JWT_PUBLIC_KEY,
        jwt.sign({ id: account.id }, config.JWT_PRIVATE_KEY, {
          expiresIn: '2d'
        }),
        { secure: false, httpOnly: true }
      );

      return LoginResult.SUCCESS;
    } else {
      return LoginResult.INCORRECT_PASSWORD;
    }
  }

  @Query(() => Boolean)
  @Authorized()
  async logOut(@Ctx() ctx: Context): Promise<boolean> {
    ctx.cookies.set(config.JWT_PUBLIC_KEY);
    return true;
  }

  @Authorized()
  @Query(() => Account)
  async currentAccount(@Ctx() ctx: Context): Promise<Account | boolean> {
    return (
      (await Account.findOne({ where: { id: ctx.state.user.id } })) || false
    );
  }

  @Query(() => Boolean)
  async requestPasswordReset(
    @Ctx() { redis }: Context,
    @Arg('email', () => String) email: string
  ): Promise<boolean> {
    const account = await Account.findOne({ where: { email } });
    if (!account) throw new Error(`Account doesn't exist with that email.`);

    const token = Math.random().toString(36).substr(2);

    await redis.set(token, account.id, 'ex', 1000 * 60 * 60 * 24 * 3);

    sendMail(token, 'RESET', email);

    return true;
  }

  @Mutation(() => Boolean)
  async resetPassword(
    @Ctx() { redis }: Context,
    @Arg('token', () => String) token: string,
    @Arg('password', () => String) password: string
  ): Promise<boolean> {
    const accountId = await redis.get(token);

    if (!accountId) throw new Error(`The token doesn't exist.`);

    await redis.del(token);

    const account = await Account.findOne({ where: { id: accountId } });

    if (!account) throw new Error(`Account doesn't exist`);

    const passwordHash = await bcrypt.hash(password, 12);

    account.passwordHash = passwordHash;

    account.save();

    return true;
  }

  @Mutation(() => Boolean)
  async verifyAccount(
    @Ctx() { redis }: Context,
    @Arg('token', () => String) token: string
  ): Promise<boolean> {
    const email = await redis.get(token);
    console.log('email: ', email);

    if (!email) throw new Error(`Token doesn't exist`);

    const account = await Account.findOne({ where: { email } });

    if (!account) throw new Error(`Account doesn't exist`);

    account.isVerified = true;

    await redis.del(token);
    account.save();
    return true;
  }

  @Mutation(() => Image)
  async uploadProfilePicture(
    @Ctx() ctx: Context,
    @Arg('picture', () => GraphQLUpload)
    { createReadStream, filename }: Upload
  ): Promise<UploadedImage> {
    createReadStream;

    const account = await Account.findOne({
      where: { id: ctx.state.user.id }
    });

    if (!account) throw new Error(`Account doesn't exist`);

    const avatarUri = await bucketUploader(filename, createReadStream());
    console.log('avatarUri: ', avatarUri);

    account.avatarUri = avatarUri;
    account.save();

    return { avatarUri, filename };
  }
}

@ObjectType()
class Image {
  @Field()
  filename: string;
  @Field()
  avatarUri: string;
}

export interface Upload {
  filename: string;
  mimetype: string;
  encoding: string;
  createReadStream: () => Stream;
}

interface UploadedImage {
  filename: string;
  avatarUri: string;
}

enum LoginResult {
  SUCCESS,
  INEXISTENT_ACCOUNT,
  UNVERIFIED_ACCOUNT,
  INCORRECT_PASSWORD
}

registerEnumType(LoginResult, {
  name: 'LoginResult',
  description: 'Return values for the login query.'
});
