--! Previous: sha1:6cff4f21d87cdd8a05153038202d41d07eab0de9
--! Hash: sha1:0e13281693c6c409a65c8f3ef57642973bbf9100

--! split: 1-current.sql
create or replace function app_public.current_user_friends() returns setof uuid as $$
  select user_id_1 from app_public.friends
    where user_id_2 = app_public.current_user_id() and status = 'accepted' union select user_id_2 from app_public.friends
    where user_id_1 = app_public.current_user_id() and status = 'accepted'
$$ language sql stable;
