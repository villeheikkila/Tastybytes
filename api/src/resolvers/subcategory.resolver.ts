import { Resolver, Query, Mutation, Arg, Authorized } from 'type-graphql';
import Category from '../entities/category.entity';
import Subcategory from '../entities/subcategory.entity';

@Resolver()
export class SubcategoryResolver {
  @Authorized()
  @Query(() => [Subcategory])
  subcategories(): Promise<Subcategory[]> {
    return Subcategory.find({ relations: ['products'] });
  }

  @Authorized()
  @Mutation(() => Subcategory)
  async createSubcategory(
    @Arg('name') name: string,
    @Arg('categoryId') categoryId: number
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
  async deleteSubategory(@Arg('id') id: string): Promise<boolean> {
    const subcategory = await Subcategory.findOne({
      where: { id },
      relations: ['products']
    });
    if (!subcategory) throw new Error('Category not found!');

    await subcategory.remove();
    return true;
  }

  @Authorized()
  @Query(() => Subcategory)
  async subcategory(@Arg('id') id: number): Promise<Subcategory | boolean> {
    const subcategory = await Subcategory.findOne({
      where: { id },
      relations: ['products']
    });

    return subcategory || false;
  }
}
