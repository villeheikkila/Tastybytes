--! Previous: sha1:d2cac4ded19f8370933355b2e8efc0d248c23a8b
--! Hash: sha1:cfff83634f85876c4dc308f91fb8ee22f2868f67

--! split: 1-current.sql
-- Enter migration here
create or replace function create_company(company_name text) returns app_public.companies
  security definer
  SET search_path = pg_catalog, public, pg_temp
  language plpgsql
as
$$
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

  insert into app_public.companies (name, is_verified, created_by) values (company_name, v_is_verified, v_current_user) returning * into v_company;

  return v_company;
end;
$$;
