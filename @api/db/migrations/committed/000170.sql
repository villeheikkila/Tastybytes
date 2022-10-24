--! Previous: sha1:e9f59706c9c65db599d192ad297949d1669e9563
--! Hash: sha1:6cff4f21d87cdd8a05153038202d41d07eab0de9

--! split: 1-current.sql
create function app_public.current_user_friends() returns setof uuid
    language sql stable security definer
    set search_path to 'pg_catalog', 'public', 'pg_temp'
    as $$
  select user_id_1 from app_public.friends
    where user_id_2 = app_public.current_user_id() and status = 'accepted' union select user_id_2 from app_public.friends
    where user_id_1 = app_public.current_user_id() and status = 'accepted'
$$;
