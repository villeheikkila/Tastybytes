--! Previous: sha1:90618ba3249cc490eec04daf8e00e66fdeb36ae1
--! Hash: sha1:04a819b0a9293e998282e65bd44e740093a6ed89

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."items"("flavor");
CREATE INDEX ON "app_public"."items"("brand_id");
