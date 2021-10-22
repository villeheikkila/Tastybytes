--! Previous: sha1:2b7a395a8bebd239d0431876f545a4c98f91cda5
--! Hash: sha1:183c602d14e2edafd533bc9da1be82e8c97565f8

--! split: 1-current.sql
create or replace function app_public.accept_friend_request(user_id uuid) returns void
  language plpgsql
  security definer
  set search_path to 'pg_catalog', 'public', 'pg_temp'
as
$$
declare
  v_current_status app_public.friends;
begin
  select *
  from app_public.friends
  where user_id_1 = user_id
    and user_id_2 = app_public.current_user_id()
  into v_current_status;

  if v_current_status is null then
    raise exception 'no such friend request exists' using errcode = 'inval';
  elseif (select status from v_current_status) = 'accepted' then
    raise exception 'you are already friends' using errcode = 'inval';
  end if;

  update app_public.friends
  set (status) = ('accepted')
  where user_id_1 = user_id
    and user_id_2 = app_public.current_user_id();
end;
$$;
