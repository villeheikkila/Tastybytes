--! Previous: sha1:5f7fe6bc21dc956c7c8f0257e85ef126cec7467a
--! Hash: sha1:bf7cdbbc2a1b37267fe220885379b20b703a3277

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."tags"("created_by");
