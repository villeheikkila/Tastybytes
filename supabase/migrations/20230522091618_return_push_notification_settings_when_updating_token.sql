set check_function_bodies = off;

drop function public.fnc__upsert_push_notification_token;

CREATE OR REPLACE FUNCTION public.fnc__upsert_push_notification_token(p_push_notification_token text)
 RETURNS profile_push_notifications
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
insert into profile_push_notifications (firebase_registration_token, created_by)
values (p_push_notification_token, auth.uid())
on conflict (firebase_registration_token)
  do update set updated_at = now(), created_by = auth.uid()
returning *;
$function$
;


