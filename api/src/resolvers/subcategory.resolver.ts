import { Resolver, Query, Mutation, Arg, Authorized, ID } from 'type-graphql';
import Category from '../entities/category.entity';
import Subcategory from '../entities/subcategory.entity';

@Resolver()
export class SubcategoryResolver {
  @Authorized()
  @Query(() => [Subcategory])
  subcategories(): Promise<Subcategory[]> {
    return Subcategory.find({ relations: ['treats'] });
  }

  @Authorized()
  @Mutation(() => Subcategory)
  async createSubcategory(
    @Arg('name', () => String) name: string,
    @Arg('categoryId', () => ID) categoryId: number
  ): Promise<Subcategory> {
    const category = await Category.findOne({
      where: { id: categoryId }
    });

    const subcategory = await Subcategory.create({
      name,
      category
    });

    await subcategory.save();
    return subcategory;
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteSubategory(@Arg('id', () => ID) id: string): Promise<boolean> {
    const subcategory = await Subcategory.findOne({
      where: { id }
    });

    if (!subcategory) throw new Error('Category not found!');

    await subcategory.remove();
    return true;
  }

  @Authorized()
  @Query(() => Subcategory)
  async subcategory(
    @Arg('id', () => ID, { nullable: true }) id?: number
  ): Promise<Subcategory | boolean> {
    const subcategory = await Subcategory.findOne({
      where: { id }
    });

    return subcategory || false;
  }

  @Authorized()
  @Query(() => [Subcategory])
  async subcategoriesByCategory(
    @Arg('categoryId', () => ID) categoryId: number
  ): Promise<Subcategory[] | boolean> {
    const category = await Category.findOne({
      where: { id: categoryId }
    });

    const subcategories = await Subcategory.find({
      where: { category }
    });

    return subcategories || false;
  }
}
