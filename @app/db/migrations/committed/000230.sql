--! Previous: sha1:7730c6c618339c2c935d826fe8f8f9ce076f4591
--! Hash: sha1:40b39cd8f99619210d560cee181bd05e57201763

--! split: 1-current.sql
-- Enter migration here
drop function app_public.check_in_statistics(u app_public.users);

CREATE or replace FUNCTION app_public.users_check_in_statistics(u app_public.users) RETURNS TABLE (
        total_check_ins int
)  AS $$
  SELECT count(*) as total_check_ins from app_public.check_ins where author_id = u.id;
$$ LANGUAGE sql STABLE;
