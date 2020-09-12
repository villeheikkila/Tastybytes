import 'reflect-metadata';
import { createConnection } from 'typeorm';
import { ApolloServer } from 'apollo-server-koa';
import { buildSchema } from 'type-graphql';
import {
  typeOrmConfig,
  JWT_PUBLIC_KEY,
  JWT_PRIVATE_KEY,
  API_PORT
} from './config';
import koa from 'koa';
import jwt from 'koa-jwt';
import jsonwebtoken from 'jsonwebtoken';
import Cookie from 'cookie';
import cors from '@koa/cors';
import path from 'path';

(async () => {
  try {
    await createConnection(typeOrmConfig);
    const schema = await buildSchema({
      resolvers: ['/service/src/**/*.resolver.{ts,js}'],
      emitSchemaFile: path.join(__dirname, '..', 'shared', 'schema.gql'),
      validate: true,
      authChecker: ({ context }) => {
        if ('state' in context) {
          return !!context.state.user;
        }
        return !!context.id;
      }
    });

    const server = new ApolloServer({
      schema,
      context: ({ ctx, connection }) => {
        if (ctx) {
          return ctx;
        }
        return connection.context;
      },
      subscriptions: {
        path: '/subscriptions',
        onConnect: (connectionParams, websocket, ctx) => {
          const parsedCookie = Cookie.parse(ctx.request.headers.cookie || '');
          const checkAccount = jsonwebtoken.verify(
            parsedCookie[JWT_PUBLIC_KEY] || '',
            JWT_PRIVATE_KEY
          ) as { id: string };
          return {
            ...ctx,
            id: checkAccount.id
          };
        }
      },
      playground: {
        settings: {
          'request.credentials': 'include'
        }
      }
    });

    const app = new koa();
    app.proxy = true;

    app.use(
      cors({
        credentials: true
      })
    );

    app.use(async (ctx, next) => {
      ctx.state = ctx.state || {};
      await next();
    });

    app.use(
      jwt({
        cookie: JWT_PUBLIC_KEY,
        secret: JWT_PRIVATE_KEY,
        passthrough: true
      })
    );

    const httpServer = app.listen(API_PORT, () =>
      console.log(
        `🚀 Server has started on the port ${API_PORT}.\n` +
          `🚀 Database connection established on port ${process.env.POSTGRES_PORT}.\n` +
          `🚀 GraphQL server at path ${server.graphqlPath}.\n` +
          `🚀 GraphQL subscription server at path ${server.subscriptionsPath}.`
      )
    );

    server.applyMiddleware({ app, path: '/graphql' });
    server.installSubscriptionHandlers(httpServer);
  } catch (error) {
    console.error(error);
  }
})();
