--! Previous: sha1:811cab95472a3124dec97c228d41e122557bd7ef
--! Hash: sha1:0139af9f6c05f6d9609e1fd10463a0c0064a2f73

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."item_edit_suggestions"("brand_id");
CREATE INDEX ON "app_public"."check_in_tags"("tag_id");
