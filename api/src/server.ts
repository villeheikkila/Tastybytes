import "reflect-metadata";
import { createConnection } from "typeorm";
import { ApolloServer } from "apollo-server";
import { buildSchema } from "type-graphql";
import { AccountResolver } from "./resolvers/AccountsResolver";
import { typeOrmConfig } from "./config";

(async () => {
  try {
    await createConnection(typeOrmConfig);
    console.log("Connected to the PostgreSQL database");
    const schema = await buildSchema({ resolvers: [AccountResolver] });
    const server = new ApolloServer({
      schema,
    });

    await server.listen(4000);
    console.log(`Server has started on ${4000}`);
  } catch (error) {
    console.log("USER: ", process.env.POSTGRES_USER);
    console.error(error);
  }
})();
