import { Resolver, Query, Mutation, Arg, Authorized, Ctx } from 'type-graphql';
import Treat from '../models/Treat';
import Account from '../models/Account';
import Review from '../models/Review';

@Resolver()
export class ReviewResolver {
  @Query(() => [Review])
  reviews(): Promise<Review[]> {
    return Review.find({ relations: ['treat', 'author'] });
  }

  @Authorized()
  @Mutation(() => Review)
  async createReview(
    @Ctx() ctx: any,
    @Arg('review') review: string,
    @Arg('score') score: number,
    @Arg('treatId') treatId: number
  ): Promise<Review> {
    const treat = await Treat.findOne({ where: { id: treatId } });
    const author = await Account.findOne({
      where: { id: ctx.state.user.id }
    });

    const reviewObject = await Review.create({
      score,
      review,
      treat,
      author
    });

    console.log(reviewObject);

    await reviewObject.save();
    return reviewObject;
  }
}
