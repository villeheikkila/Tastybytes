import { InputType, Field } from "type-graphql";

@InputType()
export class CreateAccountInput {
  @Field()
  firstName: string;

  @Field()
  lastName: string;

  @Field()
  email: string;
}
