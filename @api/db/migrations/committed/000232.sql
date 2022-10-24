--! Previous: sha1:69cfa5212b335470e5a4c52ea0c1baef44db3b59
--! Hash: sha1:8123fbd861546bd2275d04820e6e1d34cad0d783

--! split: 1-current.sql
-- Enter migration here
DROP FUNCTION app_public.users_check_in_statistics (u app_public.users);

CREATE OR REPLACE FUNCTION app_public.users_check_in_statistics (u app_public.users)
  RETURNS TABLE (
    total_check_ins int,
    unique_check_ins int
  )
  AS $$
  SELECT
    count(*) AS total_check_ins,
    count(DISTINCT item_id) AS unique_check_ins
  FROM
    app_public.check_ins
  WHERE
    author_id = u.id;

$$
LANGUAGE sql
STABLE;
