--! Previous: sha1:cabbd2a5c27fecc8562c7635013191fe3384eb19
--! Hash: sha1:3d04e56333730881653ffac268294d80e5d3e31b

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.accept_friend_request(sender_id uuid) RETURNS boolean
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
    raise exception 'You must log in to accept a friendship relation' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.friend_requests where receiver_id = v_current_user and sender_id = sender_id) into v_request_exists;

  if v_request_exists is false then
    raise exception 'No such friend request exists' using errcode = 'INVAL';
  end if;

  select exists(select 1 from app_public.friends where (user_id_1 = v_current_user and user_id_2 = sender_id) or (user_id_2 = v_current_user and user_id_1 = sender_id)) into v_already_friends;


  if v_already_friends is true then
    raise exception 'You are already friends' using errcode = 'INVAL';
  end if;

  insert into app_public.friends (user_id_1, user_id_2) values (v_current_user, friend_id), (friend_id, v_current_user);

  return true;
end;
$$;
