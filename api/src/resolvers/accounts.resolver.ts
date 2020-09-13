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
    @Arg('account') { password, ...rest }: AccountInput
  ): Promise<Account> {
    const passwordHash = await bcrypt.hash(password, 10);

    const account = Account.create({
      ...rest,
      passwordHash
    });

    await account.save();
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
}
