import { InputType, Field, Int, ID } from 'type-graphql';
import { Min, Max, Length } from 'class-validator';

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
  @Length(5, 500)
  review: string;
}
