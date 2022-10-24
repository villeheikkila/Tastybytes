--! Previous: sha1:afad7062967508da9399864a981bb24d57abac75
--! Hash: sha1:bc6cee2346c94aafeb56e3b109b4eac7b955f09b

--! split: 1-current.sql
create function app_public.delete_friend(friend_id uuid) RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS
$$
declare
  v_is_friends   boolean;
  v_current_user uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to remove a friend request or friendship' using errcode = 'LOGIN';
  end if;

  select exists(select 1
                from app_public.friends
                where (user_id_1 = v_current_user and user_id_2 = friend_id)
                   or (user_id_2 = v_current_user and user_id_1 = friend_id))
  into v_is_friends;

  if v_is_friends is false then
    raise exception 'There is no such friend relation' using errcode = 'INVAL';
  end if;

  delete
  from app_public.friends
  where (user_id_1 = v_current_user and user_id_2 = friend_id)
     or (user_id_2 = v_current_user and user_id_1 = friend_id);
end;
$$;
