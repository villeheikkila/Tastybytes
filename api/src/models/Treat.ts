import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  ManyToOne
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Review from './Review';
import Account from './Account';
import Company from './Company';
import { Lazy } from '../utils/helpers';

@Entity()
@ObjectType()
export default class Treat extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column()
  name: string;

  @OneToMany(() => Review, (review) => review.treat, { lazy: true })
  @Field(() => [Review])
  reviews: Lazy<Review[]>;

  @ManyToOne(() => Account, { lazy: true, nullable: true })
  @Field(() => Account)
  createdBy?: Lazy<Account>;

  @ManyToOne(() => Company, { lazy: true, nullable: true })
  @Field(() => Company)
  producedBy?: Lazy<Company>;
}
