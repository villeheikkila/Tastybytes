import { Field, ID, ObjectType } from 'type-graphql';
import {
  BaseEntity,
  CreateDateColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn
} from 'typeorm';
import { Lazy } from '../utils/helpers';
import Account from '../entities/account.entity';

@ObjectType()
class ExtendedBaseEntity extends BaseEntity {
  @Field(() => ID)
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Account, { lazy: true, nullable: true })
  @Field(() => Account)
  createdBy?: Lazy<Account>;

  @ManyToOne(() => Account, { lazy: true, nullable: true })
  @Field(() => Account)
  updatedBy?: Lazy<Account>;

  @Field()
  @CreateDateColumn()
  createdDate: Date;

  @Field()
  @UpdateDateColumn()
  updatedDate: Date;
}

export default ExtendedBaseEntity;
