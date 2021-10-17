--! Previous: sha1:ce38805da6df5e81c976a70bbe355e19619a5d7a
--! Hash: sha1:c5d7ec5df0badc5b9513ccdb9108c5f8826128c4

--! split: 1-current.sql
-- Enter migration here
create function app_public.current_user_is_privileged() returns boolean
  language sql stable security definer
  set search_path to 'pg_catalog', 'public', 'pg_temp'
as
$$
with current_user_roles as (
  select role
  from app_private.user_secrets where user_id = (select id from app_public.current_user())
)
select case when role = 'moderator' or role = 'admin' then true else false end as is_privileged
from current_user_roles;
$$
