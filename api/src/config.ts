import { SnakeNamingStrategy } from 'typeorm-naming-strategies';
import { PostgresConnectionOptions } from 'typeorm/driver/postgres/PostgresConnectionOptions';

export const typeOrmConfig: PostgresConnectionOptions = {
  type: 'postgres',
  host: 'db',
  port: parseInt(process.env.POSTGRES_PORT as string),
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DB,
  synchronize: true,
  logging: true,
  entities: [__dirname + '/entities/*.entity.{ts,js}'],
  migrations: [__dirname + '/migrations/*.migration.{ts,js}'],
  namingStrategy: new SnakeNamingStrategy(),
  cli: {
    migrationsDir: __dirname + '/migrations'
  }
};

export const JWT_PUBLIC_KEY = process.env.JWT_PUBLIC_KEY as string;
export const JWT_PRIVATE_KEY = process.env.JWT_PRIVATE_KEY as string;
export const API_PORT = parseInt(process.env.API_PORT as string);
export const RECAPTCHA_SECRET_KEY = process.env.RECAPTCHA_SECRET_KEY as string;
export const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY as string;
export const EMAIL_SENDER = process.env.EMAIL_SENDER as string;
export const DOMAIN = process.env.DOMAIN as string;
export const AWS_S3_ACCESS_KEY = process.env.AWS_S3_ACCESS_KEY as string;
export const AWS_S3_SECRET_ACCESS_KEY = process.env
  .AWS_S3_SECRET_ACCESS_KEY as string;
export const AWS_S3_BUCKET_NAME = process.env.AWS_S3_BUCKET_NAME as string;
