--! Previous: sha1:eb2d8dcd3af5bf0ca72179cca5f3047f8ed85b7a
--! Hash: sha1:d25dd3f823bb1fba83905b86dcfaadb9fa60fbbc

--! split: 1-current.sql
-- Enter migration here
drop policy select_all on app_public.brands;
CREATE POLICY select_all ON app_public.brands
  FOR SELECT
    USING (TRUE);
