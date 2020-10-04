import { Entity, Column, OneToMany, ManyToOne, RelationId } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import Category from './category.entity';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';
import { TypeormLoader } from 'type-graphql-dataloader';

@Entity()
@ObjectType()
export default class Subcategory extends ExtendedBaseEntity {
  @Field(() => String)
  @Column({ unique: true })
  name: string;

  @Field(() => Boolean)
  @Column({ default: true })
  isPublished: boolean;

  @OneToMany(() => Treat, (treat) => treat.subcategory, {
    lazy: true,
    nullable: true
  })
  @TypeormLoader(() => Treat, (treat: Treat) => treat.subcategoryId, {
    selfKey: true
  })
  @Field(() => [Treat])
  treats: Lazy<Treat[]>;

  @ManyToOne(() => Category, { lazy: true, nullable: true })
  @TypeormLoader(
    () => Category,
    (subcategory: Subcategory) => subcategory.categoryId
  )
  @Field(() => Category)
  category?: Lazy<Category>;

  @RelationId((subcategory: Subcategory) => subcategory.category)
  categoryId?: string;
}
