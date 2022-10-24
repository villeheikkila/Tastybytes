--! Previous: sha1:4616bf23a59fe307739c463ad807dc88be6feabf
--! Hash: sha1:f3e6d27ba114902bf3e6c70fc09e6c30fde673f9

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."items_tags"("item_id");
