import 'reflect-metadata';
import { createConnection, getConnection } from 'typeorm';
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
import { graphqlUploadKoa } from 'graphql-upload';
import {
  fieldExtensionsEstimator,
  getComplexity,
  simpleEstimator
} from 'graphql-query-complexity';
import { separateOperations } from 'graphql';
import Redis from 'ioredis';
import { ApolloServerLoaderPlugin } from 'type-graphql-dataloader';

(async () => {
  try {
    const conn = await createConnection(typeOrmConfig);
    const redis = new Redis({ host: 'redis' });

    const schema = await buildSchema({
      resolvers: [__dirname + '/resolvers/*.resolver.{ts,js}'],
      emitSchemaFile: path.resolve(__dirname, '../shared/schema.gql'),
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
      uploads: false,
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
      },
      plugins: [
        {
          requestDidStart: () => ({
            didResolveOperation({ request, document }) {
              const complexity = getComplexity({
                schema,
                query: request.operationName
                  ? separateOperations(document)[request.operationName]
                  : document,
                variables: request.variables,
                estimators: [
                  fieldExtensionsEstimator(),
                  simpleEstimator({ defaultComplexity: 1 })
                ]
              });
              if (complexity >= 20) {
                throw new Error(
                  `The complexity of ${complexity} is over 20 and therefore not allowed.`
                );
              }
              console.log('Used query complexity points:', complexity);
            }
          })
        },
        ApolloServerLoaderPlugin({
          typeormGetConnection: getConnection
        })
      ]
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
      ctx.redis = redis;
      await next();
    });

    app.use(
      jwt({
        cookie: JWT_PUBLIC_KEY,
        secret: JWT_PRIVATE_KEY,
        passthrough: true
      })
    );

    app.use(
      graphqlUploadKoa({
        maxFileSize: 10000000,
        maxFiles: 20
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

    const cleanup = async () => {
      await conn.close();

      setTimeout(function () {
        console.error('Could not close connections in time, forcing shut down');
        process.exit(1);
      }, 30 * 1000);
    };

    process.on('SIGINT', cleanup);
    process.on('SIGTERM', cleanup);
  } catch (error) {
    console.error(error);
  }
})();
