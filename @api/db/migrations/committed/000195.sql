--! Previous: sha1:294bb99163473836204da0877ac5ed7f56d8c7b8
--! Hash: sha1:47a937a253b6caa26bfca94fec294302ec051006

--! split: 1-current.sql
-- Enter migration here

create or replace function app_public.current_user_friends() returns setof uuid
    language sql stable security definer
    set search_path to 'pg_catalog', 'public', 'pg_temp'
    as $$
  select user_id_1 as user_id from app_public.friends
    where user_id_2 = app_public.current_user_id() and status = 'accepted' union select user_id_2 as user_id from app_public.friends
    where user_id_1 = app_public.current_user_id() and status = 'accepted'
$$;

create policy select_friends_or_public_check_ins on app_public.check_ins for select using ((author_id in ( select app_public.current_user_friends() as current_user_friends)));
