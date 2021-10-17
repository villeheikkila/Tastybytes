--! Previous: sha1:285937b4cd43d5d4a44aa57acc681bf8ef226cb1
--! Hash: sha1:338463cf02a139535068dee752b6d60998ac22d4

--! split: 1-current.sql
-- Enter migration here
CREATE FUNCTION  app_public.create_company(name text) RETURNS app_public.companies
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_company app_public.companies;
begin
  if name is null then
    raise exception 'The company name is required' using errcode = 'MODAT';
  end if;

  insert into app_public.companies (name) values (name) returning * into v_company;
  select * into v_company from app_public.companies where id = v_company.id;
  return v_company;
end;
$$;

COMMENT ON FUNCTION app_public.create_company(name text) IS 'Creates a new company. All arguments are required.';
