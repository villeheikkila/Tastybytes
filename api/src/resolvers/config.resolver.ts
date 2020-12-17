import { Resolver, Query, Authorized, ObjectType, Field } from 'type-graphql';
import config from '../config';

@Resolver()
export class ConfigResolver {
  @Query(() => Config)
  configs(): Config {
    return {
      recaptchaSiteKey: config.RECAPTCHA_SITE_KEY
    };
  }
}

@ObjectType()
class Config {
  @Field()
  recaptchaSiteKey: string;
}
