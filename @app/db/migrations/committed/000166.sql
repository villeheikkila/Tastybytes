--! Previous: sha1:898ef15946e307861f406dc89b6fb96fcb577dbb
--! Hash: sha1:aec05bf949edccbc568360ff8e63a6ed31af4564

--! split: 1-current.sql
-- Enter migration here
drop function create_company(text);

create function create_company(company_name text) returns app_public.companies
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

comment on function create_company(text) is 'Creates a new company. All arguments are required.';
