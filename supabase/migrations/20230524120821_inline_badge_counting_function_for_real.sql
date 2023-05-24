set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__update_notification_badges()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_device_tokens        text[];
  v_current_device_token text;
  v_number_of_unread     int;
begin
  select array_agg(firebase_registration_token)
  from profile_push_notifications
  where created_by = new.profile_id
  into v_device_tokens;

  select count(1) from notifications where profile_id = new.profile_id and seen_at is null into v_number_of_unread;

  if array_length(v_device_tokens, 1) is null or array_length(v_device_tokens, 1) = 0 then
    return new;
  else
    foreach v_current_device_token in array v_device_tokens
      loop
        perform fnc__post_request(url, headers, body)
        from fnc__get_push_notification_request(v_current_device_token, jsonb_build_object('apns',
                                                                                           json_build_object('payload',
                                                                                                             json_build_object(
                                                                                                               'aps',
                                                                                                               jsonb_build_object(
                                                                                                                 'badge',
                                                                                                                 v_number_of_unread)))));
      end loop;
  end if;
  return new;
end;
$function$
;


