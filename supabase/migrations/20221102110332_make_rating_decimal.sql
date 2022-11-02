DROP VIEW IF EXISTS "public"."csv_export" CASCADE;

ALTER TABLE "public"."check_ins"
    ALTER COLUMN "rating" SET data TYPE numeric USING "rating"::numeric;

