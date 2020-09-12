import { Resolver, Query, Mutation, Arg, Authorized, Ctx } from 'type-graphql';
import Treat from '../entities/treat.entity';
import Company from '../entities/company.entity';
import Account from '../entities/account.entity';
import { GraphQLError } from 'graphql';
import { Context } from 'koa';

@Resolver()
export class TreatResolver {
  @Authorized()
  @Query(() => [Treat])
  treats(): Promise<Treat[]> {
    return Treat.find({ relations: ['producedBy', 'createdBy', 'reviews'] });
  }

  @Authorized()
  @Query(() => Treat)
  async treat(@Arg('id') id: number): Promise<Treat | boolean> {
    return (await Treat.findOne({ where: { id } })) || false;
  }
  @Authorized()
  @Query(() => [Treat])
  // TODO: Add more search terms
  async searchTreats(@Arg('searchTerm') searchTerm: string): Promise<Treat[]> {
    const allTreats = await Treat.find({
      relations: ['producedBy', 'createdBy', 'reviews']
    });

    // TODO: Do the search in the database layer
    const filteredResults = allTreats.filter(({ name }) =>
      new RegExp(searchTerm, 'ig').test(name)
    );

    return filteredResults;
  }

  @Authorized()
  @Mutation(() => Treat)
  async createTreat(
    @Ctx() ctx: Context,
    @Arg('name') name: string,
    @Arg('producedBy') producedById: number
  ): Promise<Treat> {
    const producedBy = await Company.findOne({ where: { id: producedById } });

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
