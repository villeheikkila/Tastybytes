set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_push_notification_request(p_receiver_id uuid, p_notification jsonb)
 RETURNS TABLE(url text, headers jsonb, body jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_url                   text;
  v_headers               jsonb;
  v_receiver_device_token text;
  v_body                  jsonb;
begin
  select concat('https://fcm.googleapis.com/v1/projects/', firebase_project_id, '/messages:send')
  from secrets v_url
  into v_url;

  select concat('{ "Content-Type": "application/json", "Authorization": "Bearer ', firebase_access_token, '" }')::jsonb
  from secrets
  into v_headers;

  select firebase_registration_token
  from profile_push_notifications
  where created_by = p_receiver_id
  into v_receiver_device_token;

  select jsonb_build_object('message',
                            jsonb_build_object('token', v_receiver_device_token) || p_notification)
  into
    v_body;

  return query (select v_url url, v_headers headers, v_body body);
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__upsert_push_notification_token(p_push_notification_token text)
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
insert into profile_push_notifications (firebase_registration_token, created_by)
values (p_push_notification_token, auth.uid())
on conflict (firebase_registration_token)
  do update set updated_at = now(), created_by = auth.uid();
$function$
;

CREATE OR REPLACE FUNCTION public.tg__remove_unused_tokens()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  delete from profile_push_notifications where updated_at < now() - interval '1 years';
  return new;
end;
$function$
;


