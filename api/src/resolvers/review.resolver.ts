import { Resolver, Query, Mutation, Arg, Authorized, Ctx } from 'type-graphql';
import Treat from '../entities/treat.entity';
import Account from '../entities/account.entity';
import Review from '../entities/review.entity';
import { Context } from 'koa';

@Resolver()
export class ReviewResolver {
  @Authorized()
  @Query(() => [Review])
  reviews(): Promise<Review[]> {
    return Review.find({ relations: ['treat', 'author'] });
  }

  @Authorized()
  @Mutation(() => Review)
  async createReview(
    @Ctx() ctx: Context,
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

    await reviewObject.save();
    return reviewObject;
  }
}
