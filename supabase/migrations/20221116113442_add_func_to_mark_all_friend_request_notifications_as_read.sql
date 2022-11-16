set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__mark_friend_request_notification_as_read()
 RETURNS SETOF notifications
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
update notifications
set seen_at = now()
where friend_request_id is not null
  and profile_id = auth.uid()
returning *;
$function$
;


