set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_location_suggestions(p_longitude double precision, p_latitude double precision)
 RETURNS SETOF locations
 LANGUAGE sql
AS $function$
SELECT *
FROM locations
ORDER BY ST_Distance(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326),
                     ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326))
$function$
;


