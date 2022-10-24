--! Previous: sha1:3d04e56333730881653ffac268294d80e5d3e31b
--! Hash: sha1:3429584c9813e110784ac85b62ef66d4259535b4

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.create_friend_request(receiver_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_request_exists boolean;
  v_already_friends boolean;
  v_current_user uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to create a friend request' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.friend_requests where (receiver_id = v_current_user and sender_id = receiver_id) or (receiver_id = receiver_id and sender_id = v_current_user)) into v_request_exists;

  if v_request_exists is true then
    raise exception 'Friend request between the given users already exists' using errcode = 'INVAL';
  end if;

  select exists(select 1 from app_public.friend_requests where (receiver_id = v_current_user and sender_id = receiver_id) or (sender_id = v_current_user and receiver_id = receiver_id)) into v_already_friends;


  if v_already_friends is true then
    raise exception 'You are already friends' using errcode = 'INVAL';
  end if;

  insert into app_public.friend_requests (sender_id, receiver_id) values (v_current_user, friend_id);

  return true;
end;
$$;
