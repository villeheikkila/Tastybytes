--! Previous: sha1:f20b42c714c773278a8449563eb7b9c0f405b692
--! Hash: sha1:6adf85bb5798700cebbacc99be861bfd16c23de9

--! split: 1-current.sql
-- Enter migration here
GRANT UPDATE (name, company_id, is_verified) ON TABLE app_public.brands TO tasted_visitor;

CREATE POLICY moderator_update ON app_public.brands
  FOR UPDATE
    USING (app_public.current_user_is_privileged ());

GRANT UPDATE (flavor, description, is_verified, brand_id, type_id, manufacturer_id) ON TABLE app_public.items TO tasted_visitor;

CREATE POLICY moderator_update ON app_public.items
  FOR UPDATE
    USING (app_public.current_user_is_privileged ());

GRANT UPDATE (name, is_verified) ON TABLE app_public.tags TO tasted_visitor;

CREATE POLICY moderator_update ON app_public.tags
  FOR UPDATE
    USING (app_public.current_user_is_privileged ());


GRANT INSERT (name, category) ON TABLE app_public.types TO tasted_visitor;

CREATE POLICY moderator_update ON app_public.types
  FOR INSERT
    WITH CHECK (app_public.current_user_is_privileged ());
