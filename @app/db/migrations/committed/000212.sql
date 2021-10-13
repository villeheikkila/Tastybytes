--! Previous: sha1:d00d7e58fa950790467ac0d1319b5907459527be
--! Hash: sha1:0479e35e63151c841e871046e2d81a7fcd093d1e

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE app_public.item_edit_suggestions TO tasted_visitor;
