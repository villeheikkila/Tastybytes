--! Previous: sha1:bece115c12b32dfe9e58678f029bdce0c8eff0c2
--! Hash: sha1:d8cb69c8feaf3b58c1a74d1833cd074ba46a2843

--! split: 1-current.sql
-- Enter migration here
alter table app_public.brands add column created_at timestamp with time zone DEFAULT now() NOT NULL;
CREATE INDEX ON "app_public"."item_edit_suggestions"("type_id");
