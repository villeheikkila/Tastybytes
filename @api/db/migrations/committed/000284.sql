--! Previous: sha1:82fcde360a0badc9dd47a215cc5615cdd8f98f55
--! Hash: sha1:8f316d6e6f78ebd88633d02aeadd5216645dddd2

--! split: 1-current.sql
create or replace function app_public.accept_friend_request(user_id uuid) returns void
  language plpgsql
  security definer
  set search_path to 'pg_catalog', 'public', 'pg_temp'
as
$$
begin
  update app_public.friends
  set status = 'accepted'
  where user_id_1 = user_id
    and user_id_2 = app_public.current_user_id();
end;
$$;
