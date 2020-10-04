import 'reflect-metadata';
import { createConnection, getConnection } from 'typeorm';
import { buildSchema } from 'type-graphql';
import {
  typeOrmConfig,
  JWT_PUBLIC_KEY,
  JWT_PRIVATE_KEY,
  API_PORT
} from './config';
import koa from 'koa';
import jwt from 'koa-jwt';
import cors from '@koa/cors';
import path from 'path';
import { graphqlUploadKoa } from 'graphql-upload';
import Redis from 'ioredis';
import apolloServer from './apolloServer';
import Account from './entities/account.entity';

(async () => {
  try {
    const connection = await createConnection(typeOrmConfig);
    const redis = new Redis({ host: 'redis' });

    const server = apolloServer(
      await buildSchema({
        resolvers: [__dirname + '/resolvers/*.resolver.{ts,js}'],
        emitSchemaFile: path.resolve(__dirname, '../shared/schema.gql'),
        validate: true,
        authChecker: async ({ context }, roles) => {
          console.log('roles: ', roles);

          if (roles.includes('ADMIN')) {
            const account = await getConnection()
              .getRepository(Account)
              .findOne({
                where: { id: context.state.user.id },
                select: ['role']
              });

            return account?.role === 'ADMIN';
          }

          if ('state' in context) {
            return !!context.state.user;
          }
          return !!context.id;
        }
      })
    );

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
      await connection.close();

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
