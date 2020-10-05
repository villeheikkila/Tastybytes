import { Entity, Column, ManyToOne, RelationId } from 'typeorm';
import { ObjectType, Field } from 'type-graphql';
import Treat from './treat.entity';
import { Lazy } from '../typeorm/lazy.util';
import ExtendedBaseEntity from '../typeorm/extendedBaseEntity';
import Account from './account.entity';
import { TypeormLoader } from 'type-graphql-dataloader';

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

  @Field(() => Treat)
  @ManyToOne(() => Treat, (treat) => treat.reviews, { lazy: true })
  @TypeormLoader(() => Treat, (review: Review) => review.treatId)
  treat: Lazy<Treat>;

  @RelationId((review: Review) => review.treat)
  treatId?: string;

  @Field(() => Account)
  @ManyToOne(() => Account, { lazy: true, nullable: true })
  @TypeormLoader(() => Account, (review: Review) => review.authorId)
  author: Lazy<Account>;

  @RelationId((review: Review) => review.author)
  authorId?: string;
}
