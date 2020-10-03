import { Entity, Column, OneToMany, ManyToOne } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import Category from './category.entity';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';

@Entity()
@ObjectType()
export default class Subcategory extends ExtendedBaseEntity {
  @Field(() => String)
  @Column({ unique: true })
  name: string;

  @Field(() => Boolean)
  @Column({ default: true })
  isPublished: boolean;

  @OneToMany(() => Treat, (treat) => treat.company, {
    lazy: true,
    nullable: true
  })
  @Field(() => [Treat])
  treats: Lazy<Treat[]>;

  @ManyToOne(() => Category, { lazy: true, nullable: true })
  @Field(() => Category)
  category?: Lazy<Category>;
}
