const config = {
  isLocal: true,
  isProd: process.env.NODE_ENV === 'production',
  ENV: process.env.NODE_ENV as string,
  API_PORT: parseInt(process.env.API_PORT as string),
  DOMAIN: process.env.DOMAIN as string,
  EMAIL_SENDER: process.env.EMAIL_SENDER as string,
  JWT_PUBLIC_KEY: process.env.JWT_PUBLIC_KEY as string,
  JWT_PRIVATE_KEY: process.env.JWT_PRIVATE_KEY as string,
  RECAPTCHA_SECRET_KEY: process.env.RECAPTCHA_SECRET_KEY as string,
  SENDGRID_API_KEY: process.env.SENDGRID_API_KEY as string,
  AWS_S3_ACCESS_KEY: process.env.AWS_S3_ACCESS_KEY as string,
  AWS_S3_SECRET_ACCESS_KEY: process.env.AWS_S3_SECRET_ACCESS_KEY as string,
  AWS_S3_BUCKET_NAME: process.env.AWS_S3_BUCKET_NAME as string,
  POSTGRES_PORT: parseInt(process.env.POSTGRES_PORT as string),
  POSTGRES_USER: process.env.POSTGRES_USER as string,
  POSTGRES_PASSWORD: process.env.POSTGRES_PASSWORD as string,
  POSTGRES_DB: process.env.POSTGRES_DB as string
};

export default config;
