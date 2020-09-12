import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Review from './review.entity';
import Account from './account.entity';
import Company from './company.entity';
import { Lazy } from '../utils/helpers';
import Category from './category.entity';

@Entity()
@ObjectType()
export default class Treat extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column()
  name: string;

  @Column({ default: true })
  isPublished: boolean;

  @OneToMany(() => Review, (review) => review.treat, { lazy: true })
  @Field(() => [Review])
  reviews: Lazy<Review[]>;

  @ManyToOne(() => Account, { lazy: true, nullable: true })
  @Field(() => Account)
  createdBy?: Lazy<Account>;

  @ManyToOne(() => Company, { lazy: true, nullable: true })
  @Field(() => Company)
  producedBy?: Lazy<Company>;

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
