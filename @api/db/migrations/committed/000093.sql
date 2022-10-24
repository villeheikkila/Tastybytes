--! Previous: sha1:22c38450b25963fdec6f98e3149cf6e9aed9de23
--! Hash: sha1:7870c2540916f75d8bf3424cd5a701ed1d81bd65

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.delete_friend_request(user_id uuid) RETURNS app_public.friend_requests
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_friend_request app_public.friend_requests;
  v_current_user uuid;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to remove a friend request' using errcode = 'LOGIN';
  end if;

  delete from app_public.friend_requests where (sender_id = v_current_user and receiver_id = user_id) or (receiver_id = v_current_user and sender_id = user_id);

  select * into v_friend_request from app_public.friend_requests where receiver_id = v_current_user or sender_id = v_current_user;

  return v_friend_request;
end;
$$;
