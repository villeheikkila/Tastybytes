import { InputType, Field, Int, ID } from 'type-graphql';
import { Min, Max } from 'class-validator';

@InputType()
export class ReviewInput {
  @Field(() => ID)
  treatId: number;

  @Field(() => Int)
  @Min(0)
  @Max(5)
  score: number;

  @Field(() => String, {
    nullable: true
  })
  review: string;
}
