import { Resolver, Query, Mutation, Arg, Authorized } from 'type-graphql';
import Treat from '../entities/treat.entity';
import Account from '../entities/account.entity';
import Review from '../entities/review.entity';
import { ReviewInput } from '../input/review.input';
import CurrentUser from '../utils/decorators/currentUser';

@Resolver()
export class ReviewResolver {
  @Authorized()
  @Query(() => [Review])
  reviews(@Arg('offset') offset?: number): Promise<Review[]> {
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
    @CurrentUser() currentUser: string,
    @Arg('review') { treatId, score, review }: ReviewInput
  ): Promise<Review> {
    console.log('currentUser', currentUser);
    const treat = await Treat.findOne({ where: { id: treatId } });

    const author = await Account.findOne({
      where: { id: currentUser },
      select: ['id']
    });

    console.log('author: ', author);

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
