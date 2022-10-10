set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__delete_current_user()
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
delete from auth.users where id = auth.uid();
delete from storage.objects where owner = auth.uid();
$function$
;


