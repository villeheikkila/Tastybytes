import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Treat from './Treat';
import Account from './Account';
import { Lazy } from '../utils/helpers';

@Entity()
@ObjectType()
export default class Review extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => Number)
  @Column({ nullable: true })
  score: number;

  @Field(() => String)
  @Column({ nullable: true })
  review: string;

  @ManyToOne(() => Treat, (treat) => treat.reviews, { lazy: true })
  @Field(() => Treat)
  treat: Lazy<Treat>;

  @ManyToOne(() => Account, (account) => account.reviews, { lazy: true })
  @Field(() => Account)
  author: Lazy<Account>;
}
