-- This file is ran once only, when you reset (or create) your database. It
-- currently grants permissions to the relevant roles and creates the required
-- extensions. It's expected that this is ran with database superuser privileges as
-- normal users often don't have sufficient permissions to install extensions.

BEGIN;
GRANT CONNECT ON DATABASE :DATABASE_NAME TO :DATABASE_OWNER;
GRANT CONNECT ON DATABASE :DATABASE_NAME TO :DATABASE_AUTHENTICATOR;
GRANT ALL ON DATABASE :DATABASE_NAME TO :DATABASE_OWNER;
ALTER SCHEMA public OWNER TO :DATABASE_OWNER;

-- Some extensions require superuser privileges, so we create them before migration time.
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
COMMIT;
