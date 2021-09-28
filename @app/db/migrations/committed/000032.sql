--! Previous: sha1:04a819b0a9293e998282e65bd44e740093a6ed89
--! Hash: sha1:b692ecda2c6bf88751f84723b4a4fc32bf854ff8

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."check_ins"("item_id");
