import dotenv from "dotenv";

const MODE = process.env.NODE_ENV || "development";

dotenv.config({
  path: `${__dirname}/../.env${MODE === "production" ? ".prod" : ""}`,
});

const Config = {
  MODE,
  DOMAIN: process.env.DOMAIN,
  SENDER: process.env.SENDER,
  ETHEREAL_USERNAME: process.env.ETHEREAL_USERNAME,
  ETHEREAL_PASSWORD: process.env.ETHEREAL_PASSWORD,
  DATABASE_URL: process.env.DATABASE_URL,
  ROOT_DATABASE_URL: process.env.ROOT_DATABASE_URL,
};

export default Config;
