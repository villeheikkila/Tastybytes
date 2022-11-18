set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__mark_all_notification_read()
 RETURNS SETOF notifications
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
update notifications
set seen_at = now()
where profile_id = auth.uid()
  and seen_at is null
returning *;
$function$
;


