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
import Subcategory from './subcategory.entity';

@Entity()
@ObjectType()
export default class Category extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column({ unique: true })
  name: string;

  @Field(() => Boolean)
  @Column({ default: true })
  isPublished: boolean;

  @OneToMany(() => Treat, (treat) => treat.company, { lazy: true })
  @Field(() => [Treat])
  treats: Lazy<Treat[]>;

  @OneToMany(() => Subcategory, (subcategory) => subcategory.category, {
    lazy: true
  })
  @Field(() => [Subcategory])
  subcategories: Lazy<Subcategory[]>;

  @Field()
  @CreateDateColumn()
  createdDate: Date;

  @Field()
  @UpdateDateColumn()
  updatedDate: Date;
}
