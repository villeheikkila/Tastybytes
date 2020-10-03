import { Entity, Column, ManyToOne } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../utils/helpers';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';

@Entity()
@ObjectType()
export default class Review extends ExtendedBaseEntity {
  @Field(() => Number)
  @Column({ nullable: true })
  score: number;

  @Field(() => String)
  @Column({ nullable: true })
  review: string;

  @Column({ default: true })
  isPublished: boolean;

  @ManyToOne(() => Treat, (treat) => treat.reviews, { lazy: true })
  @Field(() => Treat)
  treat: Lazy<Treat>;
}
