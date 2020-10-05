export const ENV = process.env.NODE_ENV as string;
export const API_PORT = parseInt(process.env.API_PORT as string);
export const DOMAIN = process.env.DOMAIN as string;
export const EMAIL_SENDER = process.env.EMAIL_SENDER as string;

export const JWT_PUBLIC_KEY = process.env.JWT_PUBLIC_KEY as string;
export const JWT_PRIVATE_KEY = process.env.JWT_PRIVATE_KEY as string;

export const RECAPTCHA_SECRET_KEY = process.env.RECAPTCHA_SECRET_KEY as string;
export const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY as string;

export const AWS_S3_ACCESS_KEY = process.env.AWS_S3_ACCESS_KEY as string;
export const AWS_S3_SECRET_ACCESS_KEY = process.env
  .AWS_S3_SECRET_ACCESS_KEY as string;
export const AWS_S3_BUCKET_NAME = process.env.AWS_S3_BUCKET_NAME as string;

export const POSTGRES_PORT = parseInt(process.env.POSTGRES_PORT as string);
export const POSTGRES_USER = process.env.POSTGRES_USER as string;
export const POSTGRES_PASSWORD = process.env.POSTGRES_PASSWORD;
export const POSTGRES_DB = process.env.POSTGRES_DB as string;
