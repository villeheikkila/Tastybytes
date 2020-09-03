import { PostgresConnectionOptions } from "typeorm/driver/postgres/PostgresConnectionOptions";
import Account from "./models/Account";

export const typeOrmConfig: PostgresConnectionOptions = {
  type: "postgres",
  host: "db",
  port: process.env.POSTGRES_PORT as any,
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  synchronize: true,
  logging: false,
  entities: [Account],
};
