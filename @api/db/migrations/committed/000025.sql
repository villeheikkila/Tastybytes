--! Previous: sha1:9e132188c4fe275823de9305b6c3b4ad7e20a6e1
--! Hash: sha1:cb4edf8673227a01fdbaad7f2f81adb4cd697c91

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."items"("brand_id");
