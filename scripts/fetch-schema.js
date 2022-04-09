require("dotenv").config();
const fs = require("fs");
const path = require("path");
const { fetch: fetchU } = require("cross-undici-fetch");

const {
  buildClientSchema,
  getIntrospectionQuery,
  printSchema,
} = require("graphql");

function fetchGraphQLSchema(url, options) {
  options = options || {}; // eslint-disable-line no-param-reassign

  return fetchU(url, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      apiKey: process.env.VITE_SUPABASE_ANON_KEY,
    },
    body: JSON.stringify({
      query: getIntrospectionQuery(),
    }),
  })
    .then((res) => res.json())
    .then((schemaJSON) => {
      if (options.readable) {
        return printSchema(buildClientSchema(schemaJSON.data));
      }

      return JSON.stringify(schemaJSON, null, 2);
    });
}

const filePath = path.join(__dirname, "../schema/", "schema.graphql");

console.log();

console.log(
  `🗞   Fetching GraphQL Schema from ${process.env.VITE_SUPABASE_URL} ...`
);

fetchGraphQLSchema(`${process.env.VITE_SUPABASE_URL}/graphql/v1`, {
  readable: true,
}).then((schema) => {
  fs.writeFileSync(filePath, schema, "utf-8");
  console.log(`✨  Saved to ${filePath}`);
  console.log(
    '💡  Be sure to run "yarn run codegen" to generate latest types.'
  );
});
