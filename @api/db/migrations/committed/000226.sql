--! Previous: sha1:4cd54a7c27be2ee7af4fc09dca66b1b9a9b719eb
--! Hash: sha1:74a04a4e036309ee8a8f44d49ddb8c8e6c3be073

--! split: 1-current.sql
-- Enter migration here
CREATE FUNCTION person_full_name(selected_user app_public.users) RETURNS text AS $$
  SELECT Count(*) from app_public.check_ins where author_id = selected_user.id;
$$ LANGUAGE sql STABLE;
