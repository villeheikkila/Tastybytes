--! Previous: sha1:a7b9dc63ce80950fba4a073843c5d83bf646493a
--! Hash: sha1:935b8e26312f32d0bdadf1268f922ca320733ed1

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE FUNCTION app_public.create_check_in(item_id integer, review text default null, rating app_public.rating default null, check_in_date date default null) RETURNS app_public.check_ins
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_public boolean;
  v_check_in app_public.check_ins;
begin
  if app_public.current_user_id() is null then
    raise exception 'You must log in to create a check in' using errcode = 'LOGIN';
  end if;
  select is_public_check_ins into v_is_public from app_public.user_settings where id = app_public.current_user_id();

  insert into app_public.check_ins (item_id, rating, review, author_id, is_public) values (item_id, rating, review, app_public.current_user_id(), v_is_public) returning * into v_check_in;

  return v_check_in;
end;
$$;
