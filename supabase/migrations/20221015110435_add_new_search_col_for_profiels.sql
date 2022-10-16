DROP INDEX IF EXISTS "public"."profiles_fts";

ALTER TABLE "public"."profiles"
   DROP COLUMN "fts";

ALTER TABLE "public"."profiles"
   ADD COLUMN "search" text GENERATED ALWAYS AS (((username || COALESCE(first_name, ''::text)) || COALESCE(last_name, ''::text))) STORED;

