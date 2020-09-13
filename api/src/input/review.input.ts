import { InputType, Field, Int, ID } from 'type-graphql';
import { Min, Max } from 'class-validator';
import { GrapQLReviewText } from '../utils/validators';

@InputType()
export class ReviewInput {
  @Field(() => ID)
  treatId: number;

  @Field(() => Int)
  @Min(0)
  @Max(5)
  score: number;

  @Field(() => GrapQLReviewText, {
    nullable: true
  })
  review: string;
}
