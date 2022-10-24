import { RedisClient } from 'redis';

declare module 'koa' {
  type State = {
    user: {
      id: string;
    };
  };

  interface Context<StateT = State> {
    state: StateT;
    redis: RedisClient;
  }
}
