drop function if exists "public"."fnc__get_push_notification_request"(p_receiver_id uuid, p_notification jsonb);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_push_notification_request(p_receiver_device_token text, p_notification jsonb)
 RETURNS TABLE(url text, headers jsonb, body jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_url                   text;
  v_headers               jsonb;
  v_body                  jsonb;
begin
  select concat('https://fcm.googleapis.com/v1/projects/', firebase_project_id, '/messages:send')
  from secrets v_url
  into v_url;

  select concat('{ "Content-Type": "application/json", "Authorization": "Bearer ', firebase_access_token, '" }')::jsonb
  from secrets
  into v_headers;

  select jsonb_build_object('message',
                            jsonb_build_object('token', p_receiver_device_token) || p_notification)
  into
    v_body;

  return query (select v_url url, v_headers headers, v_body body);
end
$function$
;

CREATE OR REPLACE FUNCTION public.tg__send_push_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_notification         jsonb;
  v_device_tokens        text[];
  v_current_device_token text;
begin
  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
    select firebase_registration_token
    from profile_push_notifications
    where send_friend_request_notifications = true
      and created_by = auth.uid()
    into v_device_tokens;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
    select firebase_registration_token
    from profile_push_notifications
    where send_reaction_notifications = true
      and created_by = auth.uid()
    into v_device_tokens;
  elseif new.tagged_in_check_in_id is not null then
    select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
    select firebase_registration_token
    from profile_push_notifications
    where send_tagged_check_in_notifications = true
      and created_by = auth.uid()
    into v_device_tokens;
  end if;

  foreach v_current_device_token in array v_device_tokens
    loop
      perform fnc__post_request(url, headers, body)
      from fnc__get_push_notification_request(v_current_device_token, v_notification);
    end loop;

  return new;
end;
$function$
;


