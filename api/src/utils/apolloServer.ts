import { ApolloServer } from 'apollo-server-koa';
import { GraphQLSchema, separateOperations } from 'graphql';
import {
  fieldExtensionsEstimator,
  getComplexity,
  simpleEstimator
} from 'graphql-query-complexity';
import { ApolloServerLoaderPlugin } from 'type-graphql-dataloader';
import config from '../config';
import jsonwebtoken from 'jsonwebtoken';
import Cookie from 'cookie';
import { getConnection } from 'typeorm';

const apolloServer = (schema: GraphQLSchema): ApolloServer =>
  new ApolloServer({
    schema,
    uploads: false,
    introspection: !config.isProd,
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
          parsedCookie[config.JWT_PUBLIC_KEY] || '',
          config.JWT_PRIVATE_KEY
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

export default apolloServer;
