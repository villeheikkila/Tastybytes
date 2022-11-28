drop function if exists "public"."fnc__get_location_insert_if_not_exist"(p_name text, p_title text, p_latitude numeric, p_longitude numeric, p_country_code character);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_location_insert_if_not_exist(p_name text, p_title text, p_latitude numeric, p_longitude numeric, p_country_code text)
 RETURNS SETOF locations
 LANGUAGE plpgsql
AS $function$
declare
  v_location locations;
begin
  select *
  from locations
  where name = p_name
    and latitude = p_latitude
    and longitude = p_longitude
    and p_country_code = country_code
  limit 1
  into v_location;

  if v_location is null then
    insert into locations (name, title, latitude, longitude, country_code, created_by)
    values (p_name, p_title, p_latitude, p_longitude, p_country_code::char(2), auth.uid())
    returning *
      into v_location;
  end if;

  return query (select * from locations l where l.id = v_location.id);
end;
$function$
;


