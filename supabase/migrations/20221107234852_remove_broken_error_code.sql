set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__current_user_has_permission(p_permission_name text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
begin
  if fnc__has_permission(auth.uid(), p_permission_name) then
    raise exception 'user has no access to this feature';
  end if;
  return true;
end ;
$function$
;


