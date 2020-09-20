module.exports = {
  client: {
    includes: ["client/src/**/*.ts"],
    service: {
      localSchemaFile: "./shared/graphql.schema.json",
    },
  },
};
