import { Resolver, Query, Mutation, Arg, Ctx, Authorized } from "type-graphql";
import Account from "../models/Account";
import jwt from "jsonwebtoken";
import { JWT_PUBLIC_KEY, JWT_PRIVATE_KEY } from "../config";
import bcrypt from "bcryptjs";

@Resolver()
export class AccountResolver {
  @Query(() => [Account])
  accounts() {
    return Account.find();
  }

  @Query(() => Account)
  account(@Arg("id") id: string) {
    return Account.findOne({ where: { id } });
  }

  @Mutation(() => Account)
  async createAccount(
    @Arg("firstName") firstName: string,
    @Arg("lastName") lastName: string,
    @Arg("email") email: string,
    @Arg("password") password: string
  ) {
    const passwordHash = await bcrypt.hash(password, 10);

    const account = Account.create({
      firstName,
      lastName,
      email,
      passwordHash,
    });

    await account.save();
    return account;
  }

  @Mutation(() => Account)
  async updateAccount(
    @Arg("id") id: string,
    @Arg("firstName") firstName: string,
    @Arg("lastName") lastName: string,
    @Arg("email") email: string
  ) {
    const account = await Account.findOne({ where: { id } });
    if (!account) throw new Error("Account not found!");
    Object.assign(account, { firstName, lastName, email });

    await account.save();
    return account;
  }

  @Mutation(() => Boolean)
  async deleteAccount(@Arg("id") id: string) {
    const account = await Account.findOne({ where: { id } });
    if (!account) throw new Error("Account not found!");

    await account.remove();
    return true;
  }

  @Query(() => Boolean)
  async logIn(
    @Ctx() ctx: any,
    @Arg("email") email: string,
    @Arg("password") password: string
  ): Promise<Boolean> {
    const account = await Account.findOne({ where: { email } });
    if (!account) return false;

    const correctPassword = await bcrypt.compare(
      password,
      account.passwordHash
    );

    if (correctPassword) {
      ctx.cookies.set(
        JWT_PUBLIC_KEY,
        jwt.sign({ id: account.id }, JWT_PRIVATE_KEY, { expiresIn: "2d" }),
        { secure: false, httpOnly: true }
      );

      return true;
    }
    return false;
  }

  @Query(() => Boolean)
  async logOut(@Ctx() ctx: any): Promise<boolean> {
    ctx.cookies.set(JWT_PUBLIC_KEY);
    return true;
  }

  @Authorized()
  @Query(() => Account)
  async currentAccount(@Ctx() ctx: any): Promise<any | null> {
    return Account.findOne({ where: { id: ctx.state.user.id } });
  }
}
