--! Previous: sha1:bf7cdbbc2a1b37267fe220885379b20b703a3277
--! Hash: sha1:898ef15946e307861f406dc89b6fb96fcb577dbb

--! split: 1-current.sql
-- Enter migration here
drop function accept_friend_request(user_id uuid);

create function accept_friend_request(user_id uuid) returns void
  security definer
  SET search_path = pg_catalog, public, pg_temp
  language plpgsql
as
$$
declare
  v_current_status  app_public.friends;
  v_current_user    uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to accept a friendship relation' using errcode = 'LOGIN';
  end if;

  select *
  from app_public.friends
  where (user_id_1 = v_current_user and user_id_2 = user_id)
     or (user_id_1 = user_id and user_id_2 = v_current_user)
  into v_current_status;

  if exists(select 1 from v_current_status) = false then
    raise exception 'No such friend request exists' using errcode = 'INVAL';
  elseif (select status from v_current_status) = 'accepted' then
    raise exception 'You are already friends' using errcode = 'INVAL';
  end if;

  update app_public.friends set (status) = ('accepted') where user_id = (select user_id_1 from v_current_status) and user_id_2 = (select user_id_2 from v_current_status);
end;
$$;

grant execute on function accept_friend_request(uuid) to tasted_visitor;
