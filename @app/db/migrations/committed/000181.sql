--! Previous: sha1:d0d1f9eeb425172811bf4cead2b5284c7cb4ecc2
--! Hash: sha1:1d859247e70c6ec1075384ae0b87ab433befb724

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_all ON app_public.companies
  FOR SELECT
    USING (TRUE);

CREATE POLICY create_companies ON app_public.companies
  FOR INSERT
    WITH CHECK (app_public.current_user_id () IS NOT NULL);
