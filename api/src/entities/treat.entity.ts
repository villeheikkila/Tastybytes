import { Entity, Column, OneToMany, ManyToOne } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Review from './review.entity';
import Company from './company.entity';
import { Lazy } from '../utils/helpers';
import Category from './category.entity';
import Subcategory from './subcategory.entity';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';

@Entity()
@ObjectType()
export default class Treat extends ExtendedBaseEntity {
  @Field(() => String)
  @Column()
  name: string;

  @Column({ default: true })
  isPublished: boolean;

  @OneToMany(() => Review, (review) => review.treat, { lazy: true })
  @Field(() => [Review])
  reviews: Lazy<Review[]>;

  @ManyToOne(() => Company, { lazy: true, nullable: true })
  @Field(() => Company)
  company?: Lazy<Company>;

  @ManyToOne(() => Category, { lazy: true, nullable: true })
  @Field(() => Category)
  category?: Lazy<Category>;

  @ManyToOne(() => Subcategory, { lazy: true, nullable: true })
  @Field(() => Subcategory)
  subcategory?: Lazy<Subcategory>;
}
