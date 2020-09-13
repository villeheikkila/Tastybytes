import { InputType, Field } from 'type-graphql';
import { GraphQLEmail } from 'graphql-custom-types';
import { GraphQLLimitedPassword, GraphQLUsername } from '../utils/validators';

@InputType()
export class AccountInput {
  @Field(() => GraphQLUsername)
  username: string;

  @Field(() => GraphQLEmail)
  email: string;

  @Field(() => GraphQLLimitedPassword)
  password: string;

  @Field({ nullable: true })
  firstName?: string;

  @Field({ nullable: true })
  lastName?: string;
}

@InputType()
export class UpdateAccountInput {
  @Field(() => GraphQLUsername, { nullable: true })
  username?: string;

  @Field(() => GraphQLEmail, { nullable: true })
  email?: string;

  @Field({ nullable: true })
  password?: string;

  @Field({ nullable: true })
  firstName?: string;

  @Field({ nullable: true })
  lastName?: string;
}

@InputType()
export class LogInInput {
  @Field(() => GraphQLUsername)
  username: string;

  @Field(() => GraphQLLimitedPassword)
  password: string;
}
