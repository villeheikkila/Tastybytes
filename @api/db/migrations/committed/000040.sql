--! Previous: sha1:8a1ba6b8cd48bac77faa2dd48e1b2617f7227e7a
--! Hash: sha1:920f3e4fb891603c809af12a4201f36690a7eedf

--! split: 1-current.sql
-- Enter migration here
CREATE FUNCTION app_public.create_company(name) RETURNS app_public.users
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_brand app_public.brands;
begin
  if name is null then
    raise exception 'The company name is required' using errcode = 'MODAT';
  end if;


  insert into app_public.companies (name) values
    (name)
    returning * into v_brand;

  select * into v_brand from app_public.brands where id = v_brand.id;

  return v_brand;
end;
$$;
