import express, { Express } from "express";
import { run } from "graphile-worker"
import { Server } from "http";
import { Middleware } from "postgraphile";

import * as middleware from "./middleware";
import { makeShutdownActions, ShutdownAction } from "./shutdownActions";
import { sanitizeEnv } from "./utils";

// Server may not always be supplied, e.g. where mounting on a sub-route
export function getHttpServer(app: Express): Server | void {
  return app.get("httpServer");
}

export function getShutdownActions(app: Express): ShutdownAction[] {
  return app.get("shutdownActions");
}

export function getWebsocketMiddlewares(
  app: Express
): Middleware<express.Request, express.Response>[] {
  return app.get("websocketMiddlewares");
}

export async function makeApp({
  httpServer,
}: {
  httpServer?: Server;
} = {}): Promise<Express> {
  sanitizeEnv();

  const isDev = process.env.NODE_ENV === "development";

  const shutdownActions = makeShutdownActions();

  if (isDev) {
    shutdownActions.push(() => {
      require("inspector").close();
    });
  }

  /*
   * Our Express server
   */
  const app = express();

  await run({
    connectionString: process.env.DATABASE_URL,
    concurrency: 5,
    noHandleSignals: false,
    pollInterval: 1000,
    taskDirectory: `${__dirname}/tasks`,
  });

  /*
   * Getting access to the HTTP server directly means that we can do things
   * with websockets if we need to (e.g. GraphQL subscriptions).
   */
  app.set("httpServer", httpServer);

  /*
   * For a clean nodemon shutdown, we need to close all our sockets otherwise
   * we might not come up cleanly again (inside nodemon).
   */
  app.set("shutdownActions", shutdownActions);

  /*
   * When we're using websockets, we may want them to have access to
   * sessions/etc for authentication.
   */
  const websocketMiddlewares: Middleware<express.Request, express.Response>[] =
    [];
  app.set("websocketMiddlewares", websocketMiddlewares);

  /*
   * Middleware is installed from the /server/middleware directory. These
   * helpers may augment the express app with new settings and/or install
   * express middleware. These helpers may be asynchronous, but they should
   * operate very rapidly to enable quick as possible server startup.
   */
  await middleware.installDatabasePools(app);
  await middleware.installWorkerUtils(app);
  await middleware.installHelmet(app);
  await middleware.installSameOrigin(app);
  await middleware.installSession(app);
  await middleware.installCSRFProtection(app);
  await middleware.installPassport(app);
  await middleware.installLogging(app);
  if (process.env.FORCE_SSL) {
    await middleware.installForceSSL(app);
  }
  await middleware.installSharedStatic(app);
  await middleware.installPostGraphile(app);
  await middleware.installSSR(app);

  /*
   * Error handling middleware
   */
  await middleware.installErrorHandler(app);
  return app;
}
