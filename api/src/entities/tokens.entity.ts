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
import Account from './account.entity';

@Entity()
@ObjectType()
export default class Token extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column({ unique: true })
  token: string;

  @Field(() => Boolean)
  @Column({ default: false })
  isUsed: boolean;

  @ManyToOne(() => Account, (account) => account.tokens, { lazy: true })
  @Field(() => Account)
  account: Lazy<Account>;

  @Field()
  @CreateDateColumn()
  createdDate: Date;

  @Field()
  @UpdateDateColumn()
  updatedDate: Date;
}
