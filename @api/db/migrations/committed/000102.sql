--! Previous: sha1:31b1ab36a5616b87afbd0e52d868498a107c846a
--! Hash: sha1:cabbd2a5c27fecc8562c7635013191fe3384eb19

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.delete_friend(friend_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_friends boolean;
  v_current_user uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to delete a friendship relation' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.friends where (user_id_1 = v_current_user and user_id_2 = friend_id) or (user_id_2 = v_current_user and user_id_1 = friend_id)) into v_is_friends;

  if v_is_friends is false then
    raise exception 'You are not friends with given user' using errcode = 'INVAL';
  end if;

  delete from app_public.friends where (user_id_1 = v_current_user and user_id_2 = friend_id) or (user_id_2 = v_current_user and user_id_1 = friend_id);

  return true;
end;
$$;
