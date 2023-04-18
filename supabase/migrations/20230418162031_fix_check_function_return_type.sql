set check_function_bodies = off;

drop function public.fnc__check_if_username_is_available;

CREATE OR REPLACE FUNCTION public.fnc__check_if_username_is_available(p_username text)
 RETURNS boolean
 LANGUAGE sql
AS $function$
select exists(select 1 from profiles where lower(username) = lower(p_username));
$function$
;


