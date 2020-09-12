import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Review from './review.entity';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';

@Entity()
@ObjectType()
export default class Account extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column()
  firstName: string;

  @Field(() => String)
  @Column()
  lastName: string;

  @Field(() => String)
  @Column()
  email: string;

  @Field(() => String)
  @Column()
  passwordHash: string;

  @OneToMany(() => Review, (review) => review.author, { lazy: true })
  @Field(() => [Review])
  reviews: Lazy<Review[]>;

  @OneToMany(() => Treat, (treat) => treat.createdBy, { lazy: true })
  @Field(() => [Treat])
  createdTreats: Lazy<Treat[]>;
}
