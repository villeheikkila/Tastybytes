import { PostgresConnectionOptions } from 'typeorm/driver/postgres/PostgresConnectionOptions';

export const typeOrmConfig: PostgresConnectionOptions = {
  type: 'postgres',
  host: 'db',
  port: parseInt(process.env.POSTGRES_PORT as string),
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  synchronize: true,
  logging: false,
  entities: [__dirname + '/entities/*.entity.{ts,js}'],
  migrations: [__dirname + '/migrations/*.migration.{ts,js}'],
  cli: {
    migrationsDir: __dirname + '/migrations'
  }
};

export const JWT_PUBLIC_KEY = process.env.JWT_PUBLIC_KEY as string;
export const JWT_PRIVATE_KEY = process.env.JWT_PRIVATE_KEY as string;
export const API_PORT = parseInt(process.env.API_PORT as string);
