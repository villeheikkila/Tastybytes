ALTER TABLE "public"."check_ins"
   DROP CONSTRAINT "check_ins_migration_id_fkey";

ALTER TABLE "public"."check_ins"
   DROP CONSTRAINT "check_ins_migration_id_key";

ALTER TABLE "public"."check_ins"
   DROP COLUMN "migration_id";

DROP INDEX IF EXISTS "public"."check_ins_migration_id_key";

ALTER TABLE "public"."products"
   DROP CONSTRAINT "products_migration_id_fkey";

ALTER TABLE "public"."products"
   DROP CONSTRAINT "products_migration_id_key";

ALTER TABLE "public"."products"
   DROP COLUMN "migration_id";

DROP INDEX IF EXISTS "public"."products_migration_id_key";

DROP PROCEDURE IF EXISTS "public"."fnc__migrate_data" (IN _creator uuid);

ALTER TABLE "public"."migration_table"
   DROP CONSTRAINT "migration_table_pkey";

DROP TABLE "public"."migration_table";

