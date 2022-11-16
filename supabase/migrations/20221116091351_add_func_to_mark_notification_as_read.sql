set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__mark_notification_as_read(p_notification_id bigint)
 RETURNS SETOF notifications
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
update notifications
set seen_at = now()
where id = p_notification_id
  and profile_id = auth.uid()
returning *;
$function$
;


