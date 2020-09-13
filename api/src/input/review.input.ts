import { InputType, Field, Int, ID } from 'type-graphql';
import { GraphQLLimitedString } from 'graphql-custom-types';
import { Min, Max } from 'class-validator';

const GraphQLCompanyConstraint = new GraphQLLimitedString(3, 1024);

@InputType()
export class ReviewInput {
  @Field(() => ID)
  treatId: number;

  @Field(() => Int)
  @Min(0)
  @Max(5)
  score: number;

  @Field(() => GraphQLCompanyConstraint, { nullable: true })
  review: string;
}
