--! Previous: sha1:7155cc11405910d21a27d847b9ca0a1ef2be16da
--! Hash: sha1:eb2d8dcd3af5bf0ca72179cca5f3047f8ed85b7a

--! split: 1-current.sql
-- Enter migration here
drop policy select_all on app_public.brands;
CREATE POLICY select_all ON app_public.brands
  FOR SELECT
    USING (FALSE);
