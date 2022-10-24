--! Previous: sha1:979f226a09e913d390168ead71ebf73461965758
--! Hash: sha1:8ffea8e2adcf8d1904684d47b99daa7741366bf9

--! split: 1-current.sql
-- Enter migration here
CREATE FUNCTION app_public.create_product(flavor text, type_id int, brand_id int, manufacturer_id int default null, description text default null) RETURNS app_public.items
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_verified boolean;
  v_item app_public.items;
  v_current_user uuid;
begin
  if app_public.current_user_id() is null then
    raise exception 'You must log in to create an item' using errcode = 'LOGIN';
  end if;

  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();
  select is_admin into v_is_verified from app_public.users where id = v_current_user;

  insert into app_public.items (flavor, type_id, brand_id, manufacturer_id, description, is_verified, created_by, updated_by) values (flavor, type_id, brand_id, manufacturer_id, description, v_is_verified, v_current_user, v_current_user) returning * into v_item;

  return v_item;
end;
$$;
