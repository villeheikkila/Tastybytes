set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__search_profiles(p_search_term text)
 RETURNS SETOF profiles
 LANGUAGE sql
AS $function$
select *
from profiles
WHERE username ilike p_search_term
   or first_name ilike p_search_term
   or last_name ilike p_search_term;
$function$
;


