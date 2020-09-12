import { Resolver, Query, Mutation, Arg, Authorized, Ctx } from 'type-graphql';
import Treat from '../models/treat.entity';
import Company from '../models/company.entity';
import Account from '../models/account.entity';
import { GraphQLError } from 'graphql';
import { Context } from 'koa';

@Resolver()
export class TreatResolver {
  @Query(() => [Treat])
  treats(): Promise<Treat[]> {
    return Treat.find({ relations: ['producedBy', 'createdBy', 'reviews'] });
  }

  @Authorized()
  @Mutation(() => Treat)
  async createTreat(
    @Ctx() ctx: Context,
    @Arg('name') name: string,
    @Arg('producedBy') producedById: number
  ): Promise<Treat> {
    const producedBy = await Company.findOne({ where: { id: producedById } });
    console.log('producedBy: ', producedBy);

    if (!producedBy) throw new GraphQLError('Each treat must have a producer');

    const createdBy = await Account.findOne({
      where: { id: ctx.state.user.id }
    });

    if (!createdBy)
      throw new GraphQLError('Each treat must have an associated creator');

    const treat = await Treat.create({
      name,
      producedBy,
      createdBy
    });

    await treat.save();
    return treat;
  }
}
