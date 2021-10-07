--! Previous: sha1:c5cc2b018d08f41a8835aa165cf28aeb23e3929c
--! Hash: sha1:7d4c997cd7ff9fb9525ca36b7890c4ceb25f7ac6

--! split: 1-current.sql
-- Enter migration here
alter table app_public.check_ins add column likes integer default 0;

create table app_public.check_in_likes (
    id serial primary key references app_public.check_ins(id) on delete cascade,
    liked_by uuid references app_public.users(id) on delete cascade
);

create function app_public.like_check_in(check_in_id integer) RETURNS app_public.check_ins
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_check_in app_public.check_ins;
  v_current_user uuid;
  v_already_liked boolean;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to like a check in' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.check_in_likes where liked_by = v_current_user and id = check_in_id) into v_already_liked;

  if v_already_liked is true then
    update app_public.check_ins set likes = likes - 1 where id = check_in_id;
    delete from app_public.check_in_likes where id = check_in_id and liked_by = v_current_user;
    select * from app_public.check_ins where id = check_in_id;
  else
    update app_public.check_ins set likes = likes + 1 where id = check_in_id;
    insert into app_public.check_in_likes (id, liked_by) values (check_in_id, v_current_user) returning * into v_check_in;
  end if;

  return v_check_in;
end;
$$;
