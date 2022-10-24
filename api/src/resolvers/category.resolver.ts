import { Resolver, Query, Mutation, Arg, Authorized, ID } from 'type-graphql';
import Category from '../entities/category.entity';

@Resolver()
export class CategoryResolver {
  @Authorized()
  @Query(() => [Category])
  categories(): Promise<Category[]> {
    return Category.find();
  }

  @Authorized()
  @Mutation(() => Category)
  async createCategory(
    @Arg('name', () => String) name: string
  ): Promise<Category> {
    const category = Category.create({
      name
    });

    await category.save();
    return category;
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteCategory(@Arg('id', () => ID) id: number): Promise<boolean> {
    const category = await Category.findOne({
      where: { id }
    });

    if (!category) throw new Error('Category not found!');

    await category.remove();
    return true;
  }

  @Authorized()
  @Query(() => Category)
  async category(@Arg('id', () => ID) id: number): Promise<Category | boolean> {
    const category = await Category.findOne({
      where: { id }
    });

    return category || false;
  }
}
