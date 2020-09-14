import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  UpdateDateColumn,
  CreateDateColumn
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Review from './review.entity';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import { GraphQLEmail } from 'graphql-custom-types';
import Token from './tokens.entity';

@Entity()
@ObjectType()
export default class Account extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column({ unique: true })
  username: string;

  @Field(() => String)
  @Column({ nullable: true })
  firstName: string;

  @Field(() => String)
  @Column({ nullable: true })
  lastName: string;

  @Field(() => String)
  @Column({ unique: true })
  email: string;

  @Field(() => String)
  @Column()
  passwordHash: string;

  @Field(() => Boolean)
  @Column({ default: false })
  isVerified: boolean;

  @OneToMany(() => Review, (review) => review.author, { lazy: true })
  @Field(() => [Review])
  reviews: Lazy<Review[]>;

  @OneToMany(() => Token, (token) => token.account, { lazy: true })
  @Field(() => [Token])
  tokens: Lazy<Token[]>;

  @OneToMany(() => Treat, (treat) => treat.createdBy, { lazy: true })
  @Field(() => [Treat])
  createdTreats: Lazy<Treat[]>;

  @CreateDateColumn()
  createdDate: Date;

  @UpdateDateColumn()
  updatedDate: Date;
}
