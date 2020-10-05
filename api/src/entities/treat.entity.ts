import { Entity, Column, OneToMany, ManyToOne, RelationId } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Review from './review.entity';
import Company from './company.entity';
import { Lazy } from '../typeorm/lazy.util';
import Category from './category.entity';
import Subcategory from './subcategory.entity';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';
import { TypeormLoader } from 'type-graphql-dataloader';

@Entity()
@ObjectType()
export default class Treat extends ExtendedBaseEntity {
  @Field(() => String)
  @Column()
  name: string;

  @Column({ default: true })
  isPublished: boolean;

  @Field(() => [Review])
  @OneToMany(() => Review, (review) => review.treat, { lazy: true })
  @TypeormLoader(() => Review, (review: Review) => review.treatId, {
    selfKey: true
  })
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

  @RelationId((treat: Treat) => treat.subcategory)
  subcategoryId?: string;

  @RelationId((treat: Treat) => treat.category)
  categoryId?: string;

  @RelationId((treat: Treat) => treat.company)
  companyId?: string;
}
