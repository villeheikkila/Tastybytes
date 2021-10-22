--! Previous: sha1:c74494aa5cadafb887de99310ede54fecfec11b5
--! Hash: sha1:2b7a395a8bebd239d0431876f545a4c98f91cda5

--! split: 1-current.sql
create or replace function app_public.accept_friend_request(user_id uuid) returns void
  language plpgsql
  security definer
  set search_path to 'pg_catalog', 'public', 'pg_temp'
as
$$
declare
  v_current_status app_public.friends;
  v_current_user   uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'you must log in to accept a friendship relation' using errcode = 'login';
  end if;

  select *
  from app_public.friends
  where (user_id_1 = v_current_user and user_id_2 = user_id)
     or (user_id_1 = user_id and user_id_2 = v_current_user)
  into v_current_status;

  if v_current_status = null then
    raise exception 'no such friend request exists' using errcode = 'inval';
  elseif (select status from v_current_status) = 'accepted' then
    raise exception 'you are already friends' using errcode = 'inval';
  end if;

  update app_public.friends
  set (status) = ('accepted')
  where user_id = (select user_id_1 from v_current_status)
    and user_id_2 = (select user_id_2 from v_current_status);
end;
$$;
