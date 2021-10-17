--! Previous: sha1:fde4867f1f3d54fd4a1ff46dc4b9e34e5aee3a6f
--! Hash: sha1:2631fde00247e4467e5ebfe389cc32e59ce3190d

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

  select coalesce(is_admin, false) into v_is_verified from app_public.users where id = v_current_user;

  insert into app_public.companies (name, is_verified, created_by) values (company_name, v_is_verified, v_current_user) returning * into v_company;

  return v_company;
end;
$$;
