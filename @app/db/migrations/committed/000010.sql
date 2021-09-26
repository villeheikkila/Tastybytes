--! Previous: sha1:fa024d356893d36f95a3d798eccd30e11a1e3a32
--! Hash: sha1:4616bf23a59fe307739c463ad807dc88be6feabf

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."items"("type_id");
CREATE INDEX ON "app_public"."types"("category");
CREATE INDEX ON "app_public"."check_ins"("item_id");
CREATE INDEX ON "app_public"."check_ins"("author");
CREATE INDEX ON "app_public"."check_ins"("location");
CREATE INDEX ON "app_public"."companies"("created_by");
CREATE INDEX ON "app_public"."items"("manufacturer");
CREATE INDEX ON "app_public"."items"("type_id");
CREATE INDEX ON "app_public"."items"("created_by");
CREATE INDEX ON "app_public"."items"("updated_by");
CREATE INDEX ON "app_public"."items_tags"("tag_id");
