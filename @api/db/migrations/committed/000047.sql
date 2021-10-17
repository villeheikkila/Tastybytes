--! Previous: sha1:e56ae50a4d38193c5a2ab1fbcd8982dddf68acec
--! Hash: sha1:e9b2874b6f11739f4c2cb4bd27bc7642594890ee

--! split: 1-current.sql
-- Enter migration here
CREATE FUNCTION app_public.create_product(flavor text, type_id int, brand_id int, description text, manufacturer_id int default null) RETURNS app_public.items
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_verified boolean;
  v_item app_public.items;
begin
  if app_public.current_user_id() is null then
    raise exception 'You must log in to create an item' using errcode = 'LOGIN';
  end if;

  select is_admin into v_is_verified from app_public.users where id = app_public.current_user_id();

  insert into app_public.items (flavor, type_id, brand_id, manufacturer_id, description, is_verified, created_by, updated_by) values (flavor, type_id, brand_id, manufacturer_id, description, v_is_verified, app_public.current_user_id(), app_public.current_user_id()) returning * into v_item;

  return v_item;
end;
$$;
