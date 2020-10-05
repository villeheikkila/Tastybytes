import { SnakeNamingStrategy } from 'typeorm-naming-strategies';
import { PostgresConnectionOptions } from 'typeorm/driver/postgres/PostgresConnectionOptions';
import config from '../config';

export const typeOrmConfig: PostgresConnectionOptions = {
  type: 'postgres',
  host: 'db',
  port: config.POSTGRES_PORT,
  username: config.POSTGRES_USER,
  password: config.POSTGRES_PASSWORD,
  database: config.POSTGRES_DB,
  synchronize: !config.isProd,
  logging: !config.isProd,
  entities: [__dirname + '/../entities/*.entity.{ts,js}'],
  migrations: [__dirname + '/../migrations/*.migration.{ts,js}'],
  namingStrategy: new SnakeNamingStrategy(),
  cli: {
    migrationsDir: __dirname + '/../migrations'
  }
};
