import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany,
  ManyToOne,
  UpdateDateColumn,
  CreateDateColumn
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import Account from './account.entity';

@Entity()
@ObjectType()
export default class Company extends BaseEntity {
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

  @ManyToOne(() => Account, { lazy: true, nullable: true })
  @Field(() => Account)
  createdBy?: Lazy<Account>;

  @Field()
  @CreateDateColumn()
  createdDate: Date;

  @Field()
  @UpdateDateColumn()
  updatedDate: Date;
}
