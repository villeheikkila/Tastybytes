--! Previous: sha1:9de425db610ae280cd9c38d38c2f99c091692b86
--! Hash: sha1:878eb1da2c2296da887c09f308f3b90d257203f5

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."brands"("created_by");
