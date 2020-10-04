import { Entity, Column, OneToMany } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import Subcategory from './subcategory.entity';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';
import { TypeormLoader } from 'type-graphql-dataloader';

@Entity()
@ObjectType()
export default class Category extends ExtendedBaseEntity {
  @Field(() => String)
  @Column({ unique: true })
  name: string;

  @Field(() => Boolean)
  @Column({ default: true })
  isPublished: boolean;

  @Field(() => [Treat])
  @OneToMany(() => Treat, (treat) => treat.category, { lazy: true })
  @TypeormLoader(() => Treat, (treat: Treat) => treat.categoryId, {
    selfKey: true
  })
  treats: Lazy<Treat[]>;

  @Field(() => [Subcategory])
  @OneToMany(() => Subcategory, (subcategory) => subcategory.category, {
    lazy: true
  })
  @TypeormLoader(
    () => Subcategory,
    (subcategory: Subcategory) => subcategory.categoryId,
    {
      selfKey: true
    }
  )
  subcategories: Lazy<Subcategory[]>;
}
