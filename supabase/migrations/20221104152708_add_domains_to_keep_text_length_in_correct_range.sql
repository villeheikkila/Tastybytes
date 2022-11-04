DROP INDEX IF EXISTS "public"."brand_name_idx";

ALTER TABLE "public"."profiles"
    DROP COLUMN "search";

CREATE DOMAIN domain__long_text AS text CONSTRAINT long_text_check CHECK ((char_length(VALUE) >= 1) AND (char_length(VALUE) <= 1024));

CREATE DOMAIN domain__short_text AS text CONSTRAINT short_text_check CHECK ((char_length(VALUE) >= 1) AND (char_length(VALUE) <= 100));

CREATE DOMAIN domain__name AS text CONSTRAINT name_check CHECK ((char_length(VALUE) >= 2) AND (char_length(VALUE) <= 16));

ALTER TABLE "public"."brand_edit_suggestions"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."brands"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."check_in_comments"
    ALTER COLUMN "content" SET data TYPE domain__long_text USING "content"::domain__long_text;

ALTER TABLE "public"."check_ins"
    ALTER COLUMN "review" SET data TYPE domain__long_text USING "review"::domain__long_text;

ALTER TABLE "public"."companies"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."company_edit_suggestions"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."product_edit_suggestions"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."products"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."profiles"
    ALTER COLUMN "first_name" SET data TYPE domain__name USING "first_name"::domain__name;

ALTER TABLE "public"."profiles"
    ALTER COLUMN "last_name" SET data TYPE domain__name USING "last_name"::domain__name;

ALTER TABLE "public"."profiles"
    ALTER COLUMN "username" SET data TYPE domain__name USING "username"::domain__name;

ALTER TABLE "public"."sub_brand_edit_suggestion"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."sub_brands"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

ALTER TABLE "public"."subcategories"
    ALTER COLUMN "name" SET data TYPE domain__short_text USING "name"::domain__short_text;

CREATE INDEX brand_name_idx ON public.products USING gist (COALESCE((name)::text, description) gist_trgm_ops);

ALTER TABLE "public"."profiles"
    ADD COLUMN "search" text GENERATED ALWAYS AS (((username)::text || COALESCE((first_name)::text, ''::text)) || COALESCE((last_name)::text, ''::text)) STORED;

