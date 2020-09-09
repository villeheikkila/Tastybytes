import { Resolver, Query, Mutation, Arg, Authorized, Ctx } from 'type-graphql';
import Treat from '../models/Treat';
import Company from '../models/Company';
import Account from '../models/Account';

@Resolver()
export class TreatResolver {
  @Query(() => [Treat])
  treats(): Promise<Treat[]> {
    return Treat.find({ relations: ['producedBy', 'createdBy', 'reviews'] });
  }

  @Authorized()
  @Mutation(() => Treat)
  async createTreat(
    @Ctx() ctx: any,
    @Arg('name') name: string,
    @Arg('producedBy') producedById: number
  ): Promise<Treat> {
    const producedBy = await Company.findOne({ where: { id: producedById } });
    const createdBy = await Account.findOne({
      where: { id: ctx.state.user.id }
    });

    const treat = await Treat.create({
      name,
      producedBy,
      createdBy
    });

    await treat.save();
    return treat;
  }
}
