--! Previous: sha1:4e905676f02ebb153b17a4de99887c68c8a56985
--! Hash: sha1:330c292aa9ca7b846af644f894257d2871f6f837

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.current_user_friends() returns setof uuid as $$
  select user_id_1 as user_id from app_public.friends
    where user_id_2 = app_public.current_user_id() and status = 'accepted' union select user_id_2 as user_id from app_public.friends
    where user_id_1 = app_public.current_user_id() and status = 'accepted'
$$ language sql stable;
