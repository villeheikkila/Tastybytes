set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__check_if_username_is_available(p_username text)
 RETURNS boolean
 LANGUAGE sql
AS $function$
select not exists(select 1 from profiles where lower(username) = lower(p_username) and id != auth.uid());
$function$
;


