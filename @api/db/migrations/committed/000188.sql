--! Previous: sha1:cfff83634f85876c4dc308f91fb8ee22f2868f67
--! Hash: sha1:7155cc11405910d21a27d847b9ca0a1ef2be16da

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_all ON app_public.categories
  FOR SELECT
    USING (TRUE);

ALTER TABLE app_public.types ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_all ON app_public.types
  FOR SELECT
    USING (TRUE);

ALTER TABLE app_public.brands ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_all ON app_public.brands
  FOR SELECT
    USING (TRUE);

ALTER TABLE app_public.items ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_all ON app_public.items
  FOR SELECT
    USING (TRUE);
