--! Previous: sha1:74a04a4e036309ee8a8f44d49ddb8c8e6c3be073
--! Hash: sha1:e9b753df89fe52ce4c08169d9343911fab127431

--! split: 1-current.sql
-- Enter migration here
drop function person_full_name(selected_user app_public.users);

CREATE FUNCTION app_public.checkInStatistics(u app_public.users) RETURNS text AS $$
  SELECT count(*) as "total-check-ins" from app_public.check_ins where author_id = u.id;
$$ LANGUAGE sql STABLE;
