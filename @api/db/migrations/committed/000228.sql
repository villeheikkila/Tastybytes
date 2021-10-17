--! Previous: sha1:e9b753df89fe52ce4c08169d9343911fab127431
--! Hash: sha1:5f197428e104fd129cd6e033189e8c3730bfeb33

--! split: 1-current.sql
-- Enter migration here
CREATE or replace FUNCTION app_public.checkInStatistics(u app_public.users) RETURNS text AS $$
  SELECT 'dasda';
$$ LANGUAGE sql STABLE;
