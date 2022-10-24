--! Previous: sha1:920f3e4fb891603c809af12a4201f36690a7eedf
--! Hash: sha1:fc7451d3f681a805bfd7a81a2313d8906bb20c87

--! split: 1-current.sql
-- Enter migration here
CREATE FUNCTION app_public.create_company(name text) RETURNS app_public.users
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
