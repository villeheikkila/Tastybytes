set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_current_profile()
 RETURNS profiles
 LANGUAGE sql
AS $function$
select * from profiles where id = auth.uid() limit 1;
$function$
;


