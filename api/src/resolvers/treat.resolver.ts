import { Resolver, Query, Mutation, Arg, Authorized, Ctx } from 'type-graphql';
import Treat from '../entities/treat.entity';
import Company from '../entities/company.entity';
import Account from '../entities/account.entity';
import { GraphQLError } from 'graphql';
import { Context } from 'koa';
import Subcategory from '../entities/subcategory.entity';
import Category from '../entities/category.entity';

@Resolver()
export class TreatResolver {
  @Authorized()
  @Query(() => [Treat])
  treats(): Promise<Treat[]> {
    return Treat.find();
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
    const allTreats = await Treat.find();

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
    @Arg('companyId') companyId: number,
    @Arg('categoryId') categoryId: number,
    @Arg('subcategoryId') subcategoryId: number
  ): Promise<Treat> {
    const company = await Company.findOne({ where: { id: companyId } });
    const category = await Category.findOne({ where: { id: categoryId } });
    const subcategory = await Subcategory.findOne({
      where: { id: subcategoryId }
    });

    if (!company) throw new GraphQLError('Each treat must have a producer');
    if (!category) throw new GraphQLError('Each treat must have a category');
    if (!subcategory)
      throw new GraphQLError('Each treat must have a subcategory');

    const createdBy = await Account.findOne({
      where: { id: ctx.state.user.id }
    });

    if (!createdBy)
      throw new GraphQLError('Each treat must have an associated creator');

    const treat = await Treat.create({
      name,
      company,
      category,
      subcategory,
      createdBy
    });

    await treat.save();
    return treat;
  }
}
