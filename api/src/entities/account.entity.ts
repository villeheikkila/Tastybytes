import {
  Entity,
  Column,
  OneToMany,
  BaseEntity,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn
} from 'typeorm';
import { ObjectType, Field, ID, Authorized } from 'type-graphql';
import Review from './review.entity';
import Treat from './treat.entity';
import { Lazy } from '../typeorm/lazy.util';
import { TypeormLoader } from 'type-graphql-dataloader';

@Entity()
@ObjectType()
export default class Account extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Field()
  @CreateDateColumn()
  createdDate: Date;

  @Field()
  @UpdateDateColumn()
  updatedDate: Date;

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

  @Field(() => String, { nullable: true })
  @Column({ nullable: true })
  avatarUri: string;

  @Authorized('ADMIN')
  @Field(() => String)
  @Column()
  passwordHash: string;

  @Field(() => Boolean)
  @Column({ default: false })
  isVerified: boolean;

  @Field(() => String, { nullable: true })
  @Column({ default: 'USER' })
  role: 'USER' | 'ADMIN';

  @Field(() => [Review])
  @OneToMany(() => Review, (review) => review.author, { lazy: true })
  @TypeormLoader(() => Review, (review: Review) => review.authorId, {
    selfKey: true
  })
  reviews: Lazy<Review[]>;

  @OneToMany(() => Treat, (treat) => treat.createdBy, { lazy: true })
  @Field(() => [Treat])
  createdTreats: Lazy<Treat[]>;
}
