--! Previous: sha1:1e794cf5589c0af69d820bff829dc7d6c1c6f997
--! Hash: sha1:90618ba3249cc490eec04daf8e00e66fdeb36ae1

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."companies"("name");
