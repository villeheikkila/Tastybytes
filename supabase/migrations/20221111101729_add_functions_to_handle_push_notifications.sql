alter table "public"."secrets" add column "firebase_project_id" text;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__send_push_notification(p_receiver_id uuid, p_title text, p_body text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_url                   text;
  v_headers               jsonb;
  v_receiver_device_token text;
  v_body                  jsonb;
  v_response_id           bigint;
begin
  select concat('https://fcm.googleapis.com/v1/projects/', firebase_project_id, '/messages:send')
  from secrets v_url
  into v_url;

  select concat('{ "Content-Type": "application/json", "Authorization": "Bearer ', firebase_access_token, '" }')::jsonb
  from secrets
  into v_headers;

  select firebase_registration_token
  from profile_push_notification_tokens
  where created_by = p_receiver_id
  into v_receiver_device_token;

  select concat('{"message":{
   "notification":{
     "title":"', p_title, '",
     "body":"', p_body, '"
   },
   "token":"',v_receiver_device_token,'"}}')::jsonb
  into v_body;

  select net.http_post(
           url := v_url,
           headers := v_headers,
           body := v_body
           ) request_id
  into v_response_id;

  return v_response_id;
end
$function$
;




