import "dotenv/config";
import pg from "pg";

const resetDatabase = async () => {
  const {
    DATABASE_AUTHENTICATOR,
    DATABASE_AUTHENTICATOR_PASSWORD,
    DATABASE_NAME,
    DATABASE_OWNER,
    DATABASE_OWNER_PASSWORD,
    DATABASE_VISITOR,
    ROOT_DATABASE_URL,
  } = process.env;

  const pgPool = new pg.Pool({
    connectionString: ROOT_DATABASE_URL,
  });

  const client = await pgPool.connect();
  try {
    await client.query(`DROP DATABASE IF EXISTS ${DATABASE_NAME};`);
    await client.query(`DROP DATABASE IF EXISTS ${DATABASE_NAME}_shadow;`);
    await client.query(`DROP DATABASE IF EXISTS ${DATABASE_NAME}_test;`);
    await client.query(`DROP ROLE IF EXISTS ${DATABASE_VISITOR};`);
    await client.query(`DROP ROLE IF EXISTS ${DATABASE_AUTHENTICATOR};`);
    await client.query(`DROP ROLE IF EXISTS ${DATABASE_OWNER};`);

    await client.query(
      `CREATE ROLE ${DATABASE_OWNER} WITH LOGIN PASSWORD '${DATABASE_OWNER_PASSWORD}' SUPERUSER;`
    );

    await client.query(
      `CREATE ROLE ${DATABASE_AUTHENTICATOR} WITH LOGIN PASSWORD '${DATABASE_AUTHENTICATOR_PASSWORD}' NOINHERIT;`
    );

    await client.query(`CREATE ROLE ${DATABASE_VISITOR};`);

    await client.query(
      `GRANT ${DATABASE_VISITOR} TO ${DATABASE_AUTHENTICATOR};`
    );

    await client.query(`CREATE DATABASE ${DATABASE_NAME};`);
    await client.query(`CREATE DATABASE ${DATABASE_NAME}_shadow;`);
    await client.query(`CREATE DATABASE ${DATABASE_NAME}_test;`);
  } finally {
    await client.release();
  }

  await pgPool.end();
};

resetDatabase();
