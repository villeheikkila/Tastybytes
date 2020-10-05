import { SnakeNamingStrategy } from 'typeorm-naming-strategies';
import { PostgresConnectionOptions } from 'typeorm/driver/postgres/PostgresConnectionOptions';
import {
  ENV,
  POSTGRES_DB,
  POSTGRES_PASSWORD,
  POSTGRES_PORT,
  POSTGRES_USER
} from '../config';

export const typeOrmConfig: PostgresConnectionOptions = {
  type: 'postgres',
  host: 'db',
  port: POSTGRES_PORT,
  username: POSTGRES_USER,
  password: POSTGRES_PASSWORD,
  database: POSTGRES_DB,
  synchronize: ENV === 'development',
  logging: ENV === 'development',
  entities: [__dirname + '/../entities/*.entity.{ts,js}'],
  migrations: [__dirname + '/../migrations/*.migration.{ts,js}'],
  namingStrategy: new SnakeNamingStrategy(),
  cli: {
    migrationsDir: __dirname + '/../migrations'
  }
};
