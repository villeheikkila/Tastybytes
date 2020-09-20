import GraphQLDatabaseLoader from '@mando75/typeorm-graphql-loader';
import { RedisClient } from 'redis';

declare module 'koa' {
  type State = {
    user: {
      id: string;
    };
  };

  interface Context<StateT = State> {
    state: StateT;
    loader: GraphQLDatabaseLoader;
    redis: RedisClient;
  }
}
