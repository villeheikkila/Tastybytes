import path from "path";
import express from "express"
import compression from "compression"
import morgan from "morgan"
import { createRequestHandler } from "@remix-run/express"
import { makePgSmartTagsFromFilePlugin } from "postgraphile/plugins"
import { resolve } from "path"
import PgSimplifyInflectorPlugin from "@graphile-contrib/pg-simplify-inflector";

const { postgraphile } = require("postgraphile");

const app = express();

const MODE = process.env.NODE_ENV;
const BUILD_DIR = path.join(process.cwd(), "server/build");

app.use(compression());
app.use(express.static("public", { maxAge: "1h" }));

const SmartTagsPlugin = makePgSmartTagsFromFilePlugin(
  resolve(__dirname, "./postgraphile.tags.jsonc")
);

app.use(
  postgraphile(
    process.env.DATABASE_URL ||
      "postgres://tasted:cUssU1LEAoZqbhsR6vev64PJnhWJleAteCnzbx_X@localhost:5440/tasted",
    "app_public",
    {
      watchPg: true,
      graphiql: true,
      enhanceGraphiql: true,
      allowExplain: true,
      appendPlugins: [SmartTagsPlugin,PgSimplifyInflectorPlugin],
      sortExport: true,
      exportGqlSchemaPath: `${__dirname}/data/schema.graphql`,
    }
  )
);

// Remix fingerprints its assets so we can cache forever
app.use(express.static("public/build", { immutable: true, maxAge: "1y" }));

app.use(morgan("tiny"));
app.all(
  "*",
  MODE === "production"
    ? createRequestHandler({ build: require("./build") })
    : (req, res, next) => {
        purgeRequireCache();
        const build = require("./build");
        return createRequestHandler({ build, mode: MODE })(req, res, next);
      }
);

const port = process.env.PORT || 3333;
app.listen(port, () => {
  console.log(`Express server listening on port ${port}`);
});

////////////////////////////////////////////////////////////////////////////////
function purgeRequireCache() {
  // purge require cache on requests for "server side HMR" this won't let
  // you have in-memory objects between requests in development,
  // alternatively you can set up nodemon/pm2-dev to restart the server on
  // file changes, we prefer the DX of this though, so we've included it
  // for you by default
  for (const key in require.cache) {
    if (key.startsWith(BUILD_DIR)) {
      delete require.cache[key];
    }
  }
}
