import {
  Entity,
  BaseEntity,
  PrimaryGeneratedColumn,
  Column,
  OneToMany
} from 'typeorm';
import { ObjectType, Field, ID } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';

@Entity()
@ObjectType()
export default class Company extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn()
  id: string;

  @Field(() => String)
  @Column()
  name: string;

  @OneToMany(() => Treat, (treat) => treat.producedBy, { lazy: true })
  @Field(() => [Treat])
  products: Lazy<Treat[]>;
}
