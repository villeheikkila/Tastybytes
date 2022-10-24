--! Previous: sha1:f8e3cb8062745e8acf6c75adeeb55fe982028b8d
--! Hash: sha1:5f796dd508cafd75a1dcd8240449be460fe7f7dc

--! split: 1-current.sql
-- Enter migration here
CREATE FUNCTION app_public.create_check_in(item_id integer, review text default null, rating app_public.rating default null, check_in_date date default null) RETURNS app_public.check_ins
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_public boolean;
  v_check_in app_public.check_ins;
  v_current_user uuid;
begin
  select id into v_current_user from app_public.current_user_id();
  if v_current_user is null then
    raise exception 'You must log in to create a check in' using errcode = 'LOGIN';
  end if;
  select is_public_check_ins into v_is_public from app_public.user_settings where id = v_current_user;

  insert into app_public.check_ins (item_id, rating, review, author_id, is_public) values (item_id, rating, review, v_current_user, v_is_public) returning * into v_check_in;

  return v_check_in;
end;
$$;
