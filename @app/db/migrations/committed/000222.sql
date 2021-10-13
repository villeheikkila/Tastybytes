--! Previous: sha1:7e0bd7374fcac1dbef4435a423b2e3198340a63b
--! Hash: sha1:f20b42c714c773278a8449563eb7b9c0f405b692

--! split: 1-current.sql
-- Enter migration here
GRANT UPDATE (name, is_verified) ON TABLE app_public.companies TO tasted_visitor;

CREATE POLICY moderator_update ON app_public.companies
  FOR UPDATE
    USING (app_public.current_user_is_privileged ());
