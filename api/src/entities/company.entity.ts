import { Entity, Column, OneToMany } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';

@Entity()
@ObjectType()
export default class Company extends ExtendedBaseEntity {
  @Field(() => String)
  @Column({ unique: true })
  name: string;

  @Field(() => Boolean)
  @Column({ default: true })
  isPublished: boolean;

  @OneToMany(() => Treat, (treat) => treat.company, { lazy: true })
  @Field(() => [Treat])
  treats: Lazy<Treat[]>;
}
