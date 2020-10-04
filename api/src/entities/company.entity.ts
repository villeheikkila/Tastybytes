import { Entity, Column, OneToMany } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';
import { TypeormLoader } from 'type-graphql-dataloader';

@Entity()
@ObjectType()
export default class Company extends ExtendedBaseEntity {
  @Field(() => String)
  @Column({ unique: true })
  name: string;

  @Field(() => Boolean)
  @Column({ default: true })
  isPublished: boolean;

  @Field(() => [Treat])
  @OneToMany(() => Treat, (treat) => treat.company, { lazy: true })
  @TypeormLoader(() => Treat, (treat: Treat) => treat.companyId, {
    selfKey: true
  })
  treats: Lazy<Treat[]>;
}
