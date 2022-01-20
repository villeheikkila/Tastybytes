import { spawn } from "child_process"

const connectionString = process.env.GM_DBURL;

if (!connectionString) {
  console.error(
    "This script should only be called from a graphile-migrate action."
  );
  process.exit(1);
}

spawn(
  process.env.PG_DUMP || "pg_dump",
  [
    "--no-sync",
    "--schema-only",
    "--no-owner",
    "--exclude-schema=graphile_migrate",
    "--exclude-schema=graphile_worker",
    "--file=../../@api/data/schema.sql",
    connectionString,
  ],
  {
    stdio: "inherit",
    shell: true,
  }
);
