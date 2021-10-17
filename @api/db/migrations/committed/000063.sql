--! Previous: sha1:c3836911fe72d552d8872a1950dba1d91ec4ac13
--! Hash: sha1:372ed6af23d9acd643a4aa8a1f98594101ef5cd1

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE FUNCTION app_public.create_company(name text) RETURNS app_public.companies
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_verified boolean;
  v_company app_public.companies;
  v_current_user uuid;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();

  if app_public.current_user_id() is null then
    raise exception 'You must log in to create a company' using errcode = 'LOGIN';
  end if;

  select is_admin into v_is_verified from app_public.users where id = v_current_user;

  insert into app_public.companies (name, is_verified, created_by) values (name, v_is_verified, v_current_user) returning * into v_company;

  return v_company;
end;
$$;
