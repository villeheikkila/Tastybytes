--! Previous: sha1:2230027d9fa9b092db516003f6ddb68ea38dbfef
--! Hash: sha1:9de425db610ae280cd9c38d38c2f99c091692b86

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE FUNCTION app_public.create_brand(name text, company_id integer) RETURNS app_public.brands
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_verified boolean;
  v_brand app_public.brands;
  v_current_user uuid;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();

  if app_public.current_user_id() is null then
    raise exception 'You must log in to create a company' using errcode = 'LOGIN';
  end if;

  select is_admin into v_is_verified from app_public.users where id = v_current_user;

  insert into app_public.brands (name, company_id, is_verified, created_by) values (name, company_id, v_is_verified, v_current_user) returning * into v_brand;

  return v_brand;
end;
$$;
