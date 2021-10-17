--! Previous: sha1:71bb2db3e5dd49dac24ab4f4621868e16b292437
--! Hash: sha1:22c38450b25963fdec6f98e3149cf6e9aed9de23

--! split: 1-current.sql
-- Enter migration here
create function app_public.delete_friend_request(user_id uuid) RETURNS app_public.friend_requests
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

  delete from app_public.friend_requests where sender_id = v_current_user and receiver_id = user_id;
  delete from app_public.friend_requests where receiver_id = v_current_user and sender_id = user_id;

  select * into v_friend_request from app_public.friend_requests where receiver_id = v_current_user or sender_id = v_current_user;

  return v_friend_request;
end;
$$;
