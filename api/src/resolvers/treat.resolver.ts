import {
  Resolver,
  Query,
  Mutation,
  Arg,
  Authorized,
  Ctx,
  ID
} from 'type-graphql';
import Treat from '../entities/treat.entity';
import Company from '../entities/company.entity';
import Account from '../entities/account.entity';
import { GraphQLError } from 'graphql';
import { Context } from 'koa';
import Subcategory from '../entities/subcategory.entity';
import Category from '../entities/category.entity';
import { ILike } from '../typeorm/ilike.util';
import { getRepository } from 'typeorm';

@Resolver()
export class TreatResolver {
  @Authorized()
  @Query(() => [Treat])
  treats(): Promise<Treat[]> {
    return getRepository(Treat).find();
  }

  @Authorized()
  @Query(() => Treat)
  async treat(@Arg('id', () => ID) id: number): Promise<Treat | boolean> {
    return (await Treat.findOne({ where: { id } })) || false;
  }

  @Authorized()
  @Query(() => [Treat])
  async searchTreats(
    @Arg('searchTerm', () => String) searchTerm: string,
    @Arg('offset', () => Number, { nullable: true }) offset?: number
  ): Promise<Treat[]> {
    // TODO: Add search by companies, categories etc
    const allTreats = await Treat.find({
      skip: offset,
      take: 10,
      where: [{ name: ILike(`%${searchTerm}%`) }]
    });

    return allTreats;
  }

  @Authorized()
  @Mutation(() => Treat)
  async createTreat(
    @Ctx() ctx: Context,
    @Arg('name', () => String) name: string,
    @Arg('companyId', () => ID) companyId: number,
    @Arg('categoryId', () => ID) categoryId: number,
    @Arg('subcategoryId', () => ID) subcategoryId: number
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
