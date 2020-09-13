import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  UpdateDateColumn,
  CreateDateColumn
} from 'typeorm';
import { ObjectType, Field, ID, InputType } from 'type-graphql';
import Review from './review.entity';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import { GraphQLEmail, GraphQLPassword } from 'graphql-custom-types';
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

  @Field(() => GraphQLEmail)
  @Column({ unique: true })
  email: string;

  @Field(() => new GraphQLPassword(6, 124))
  @Column()
  passwordHash: string;

  @OneToMany(() => Review, (review) => review.author, { lazy: true })
  @Field(() => [Review])
  reviews: Lazy<Review[]>;

  @OneToMany(() => Treat, (treat) => treat.createdBy, { lazy: true })
  @Field(() => [Treat])
  createdTreats: Lazy<Treat[]>;

  @CreateDateColumn()
  createdDate: Date;

  @UpdateDateColumn()
  updatedDate: Date;
}
