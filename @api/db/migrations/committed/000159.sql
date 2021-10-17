--! Previous: sha1:efdae1ee1c523abceba2d0d3dd1fea4c835af8dc
--! Hash: sha1:bece115c12b32dfe9e58678f029bdce0c8eff0c2

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."item_edit_suggestions"("type_id");
