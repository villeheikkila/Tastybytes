--! Previous: sha1:81919f693a6a90086fffb1adf2cf637e6c1850fe
--! Hash: sha1:60e8ccbf3f72621c41f4e005ad46f3b9f64d4269

--! split: 1-current.sql
-- Enter migration here
drop function create_product(flavor text, type_id integer, brand_id integer, manufacturer_id integer, description text);

create function create_item(flavor text, type_id integer, brand_id integer, manufacturer_id integer DEFAULT NULL::integer, description text DEFAULT NULL::text) returns app_public.items
  security definer
  SET search_path = pg_catalog, public, pg_temp
  language plpgsql
as
$$
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

grant execute on function create_item(text, integer, integer, integer, text) to tasted_visitor;
