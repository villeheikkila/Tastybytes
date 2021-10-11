--! Previous: sha1:ba1b1ddc336704502035f7acafb8ee3e36c17451
--! Hash: sha1:d4215b27bf906850ac03aaae90d091b45b8b3bf7

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."item_edit_suggestions"("manufacturer_id");
CREATE INDEX ON "app_public"."item_edit_suggestions"("author_id");
CREATE INDEX ON "app_public"."item_edit_suggestions"("item_id");
