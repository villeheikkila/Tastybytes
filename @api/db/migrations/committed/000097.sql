--! Previous: sha1:945897ad8ca49a6497fe866f4c51a2febf6da0a3
--! Hash: sha1:73a6eb7b911fe9de0521ae4b85389239827ffe3f

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.delete_friend_request(user_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_friend_request app_public.friend_requests;
  v_current_user uuid;
  v_friend_request_exists boolean;
begin
  select id into v_current_user from app_public.users where id = app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to remove a friend request' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.friend_requests where (sender_id = v_current_user and receiver_id = user_id)) into v_friend_request_exists;

  if (v_friend_request_exists) is null then
    raise exception 'There is no friend request between the given users`' using errcode = 'INVAL';
  end if;

  delete from app_public.friend_requests where (sender_id = v_current_user and receiver_id = user_id) or (receiver_id = v_current_user and sender_id = user_id);

  select * into v_friend_request from app_public.friend_requests where receiver_id = v_current_user or sender_id = v_current_user;

  return true;
end;
$$;
