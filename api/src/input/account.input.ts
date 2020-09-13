import { InputType, Field } from 'type-graphql';
import {
  GraphQLPassword,
  GraphQLEmail,
  GraphQLLimitedString
} from 'graphql-custom-types';

const GraphQLUsername = new GraphQLLimitedString(3, 16);
const GraphQLLimitedPassword = new GraphQLPassword(6);

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

  @Field(() => GraphQLLimitedPassword, { nullable: true })
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
