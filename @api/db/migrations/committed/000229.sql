--! Previous: sha1:5f197428e104fd129cd6e033189e8c3730bfeb33
--! Hash: sha1:7730c6c618339c2c935d826fe8f8f9ce076f4591

--! split: 1-current.sql
-- Enter migration here
CREATE or replace FUNCTION app_public.check_in_statistics(u app_public.users) RETURNS TABLE (
        total_check_ins int
)  AS $$
  SELECT count(*) as total_check_ins from app_public.check_ins where author_id = u.id;
$$ LANGUAGE sql STABLE;
