drop function if exists "public"."fnc_upsert_push_notification_token"(p_push_notification_token text);

CREATE OR REPLACE FUNCTION public.fnc__upsert_push_notification_token(p_push_notification_token text)
 RETURNS SETOF profile_push_notification_tokens
 LANGUAGE sql
AS $function$
insert into profile_push_notification_tokens (firebase_registration_token, created_by)
values (p_push_notification_token, auth.uid())
on conflict (firebase_registration_token) do update set updated_at = now()
returning *;
$function$
;