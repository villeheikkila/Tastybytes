import { Resolver, Query, Mutation, Arg, Authorized } from 'type-graphql';
import Category from '../entities/category.entity';

@Resolver()
export class CategoryResolver {
  @Authorized()
  @Query(() => [Category])
  categories(): Promise<Category[]> {
    return Category.find({ relations: ['products'] });
  }

  @Authorized()
  @Mutation(() => Category)
  async createCategory(@Arg('name') name: string): Promise<Category> {
    const category = Category.create({
      name
    });

    await category.save();
    return category;
  }

  @Authorized()
  @Mutation(() => Boolean)
  async deleteCategory(@Arg('id') id: string): Promise<boolean> {
    const category = await Category.findOne({
      where: { id },
      relations: ['products']
    });
    if (!category) throw new Error('Category not found!');

    await category.remove();
    return true;
  }

  @Authorized()
  @Query(() => Category)
  async category(@Arg('id') id: number): Promise<Category | boolean> {
    const category = await Category.findOne({
      where: { id },
      relations: ['products']
    });

    return category || false;
  }
}
