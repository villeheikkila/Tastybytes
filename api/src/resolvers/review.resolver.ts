import { Resolver, Query, Mutation, Arg, Authorized, Ctx } from 'type-graphql';
import Treat from '../entities/treat.entity';
import Account from '../entities/account.entity';
import Review from '../entities/review.entity';
import { Context } from 'koa';
import { ReviewInput } from '../input/review.input';

@Resolver()
export class ReviewResolver {
  @Authorized()
  @Query(() => [Review])
  reviews(
    @Ctx() ctx: Context,
    @Arg('offset') offset?: number
  ): Promise<Review[]> {
    return Review.find({
      relations: ['author', 'treat'],
      skip: offset,
      take: 3,
      order: {
        createdDate: 'ASC'
      }
    });
  }

  @Authorized()
  @Mutation(() => Review)
  async createReview(
    @Ctx() ctx: Context,
    @Arg('review') { treatId, score, review }: ReviewInput
  ): Promise<Review> {
    const treat = await Treat.findOne({ where: { id: treatId } });
    const createdBy = await Account.findOne({
      where: { id: ctx.state.user.id }
    });

    const reviewObject = await Review.create({
      score,
      review,
      treat,
      createdBy
    });

    await reviewObject.save();
    return reviewObject;
  }
}
