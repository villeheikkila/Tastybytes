import { createParamDecorator } from 'type-graphql';
import { Context } from 'koa';

export default function CurrentUser() {
  return createParamDecorator<Context>(({ context }) => context.state.user.id);
}
