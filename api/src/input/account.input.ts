import { InputType, Field } from 'type-graphql';
import { Length, IsEmail } from 'class-validator';

@InputType()
export class AccountInput {
  @Length(3, 24)
  @Field(() => String)
  username: string;

  @IsEmail()
  @Field(() => String)
  email: string;

  @Length(6, 255)
  @Field(() => String)
  password: string;

  @Field()
  captchaToken: string;

  @Length(2, 255)
  @Field({ nullable: true })
  firstName?: string;

  @Length(2, 255)
  @Field({ nullable: true })
  lastName?: string;
}

@InputType()
export class UpdateAccountInput {
  @Length(3, 24)
  @Field(() => String, { nullable: true })
  username?: string;

  @IsEmail()
  @Field(() => String, { nullable: true })
  email?: string;

  @Length(6, 255)
  @Field({ nullable: true })
  password?: string;

  @Length(2, 255)
  @Field({ nullable: true })
  firstName?: string;

  @Length(2, 255)
  @Field({ nullable: true })
  lastName?: string;
}

@InputType()
export class LogInInput {
  @Length(3, 255)
  @Field(() => String)
  username: string;

  @Length(6, 255)
  @Field(() => String)
  password: string;
}
