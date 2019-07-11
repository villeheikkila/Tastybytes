import { prisma } from "./generated/prisma-client";
import datamodelInfo from "./generated/nexus-prisma";
import * as path from "path";
import { makePrismaSchema } from "nexus-prisma";
import { GraphQLServer } from "graphql-yoga";
import { permissions } from "./permissions";
import * as allTypes from "./resolvers";
require("dotenv").config();

const schema = makePrismaSchema({
  types: allTypes,

  prisma: {
    datamodelInfo,
    client: prisma
  },

  outputs: {
    schema: path.join(__dirname, "./generated/schema.graphql"),
    typegen: path.join(__dirname, "./generated/nexus.ts")
  },

  nonNullDefaults: {
    input: false,
    output: false
  },

  typegenAutoConfig: {
    sources: [
      {
        source: path.join(__dirname, "./types/index.ts"),
        alias: "types"
      }
    ],
    contextType: "types.Context"
  }
});

const server = new GraphQLServer({
  schema,
  middlewares: [permissions],
  context: request => {
    return {
      ...request,
      prisma
    };
  }
});

server.start(() => console.log("Server is running on http://localhost:4000"));
