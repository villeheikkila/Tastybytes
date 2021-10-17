--! Previous: sha1:935b8e26312f32d0bdadf1268f922ca320733ed1
--! Hash: sha1:c5331d94b3cd6f108eef877ae2a126a40a818f0b

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

  insert into app_public.check_ins (item_id, rating, review, author_id) values (item_id, rating, review, app_public.current_user_id()) returning * into v_check_in;

  return v_check_in;
end;
$$;
