import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  UpdateDateColumn,
  CreateDateColumn,
  ManyToOne
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import Category from './category.entity';

@Entity()
@ObjectType()
export default class Subcategory extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column({ unique: true })
  name: string;

  @Field(() => Boolean)
  @Column({ default: true })
  isPublished: boolean;

  @OneToMany(() => Treat, (treat) => treat.producedBy, {
    lazy: true,
    nullable: true
  })
  @Field(() => [Treat])
  products: Lazy<Treat[]>;

  @ManyToOne(() => Category, { lazy: true, nullable: true })
  @Field(() => Category)
  category?: Lazy<Category>;

  @Field()
  @CreateDateColumn()
  createdDate: Date;

  @Field()
  @UpdateDateColumn()
  updatedDate: Date;
}
