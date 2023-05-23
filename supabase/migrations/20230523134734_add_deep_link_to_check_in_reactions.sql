set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_deeplink(p_type text, id integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
begin
  return 'tastybytes://deeplink/' || p_type || '/' || id;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_check_in_reaction_notification(p_check_in_reaction_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_title text;
  v_body  text;
  v_check_in_id int;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' reacted to your check-in of ', b.name, case
                                                                             when sb.name is not null
                                                                               then
                                                                               concat(' ', sb.name, ' ')
                                                                             else
                                                                               ' '
    end, pr.name, ' from ', bo.name)
  from check_in_reactions cir
         left join check_ins c on cir.check_in_id = c.id
         left join profiles p on p.id = cir.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where cir.id = p_check_in_reaction_id
  into v_body;

  select c.id from check_in_reactions cir
         left join check_ins c on cir.check_in_id = c.id where cir.id = p_check_in_reaction_id into v_check_in_id;

  return jsonb_build_object('notification', jsonb_build_object('title', v_title, 'body', v_body), 'data', jsonb_build_object('link', fnc__create_deeplink('checkins', v_check_in_id)));
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_push_notification_request(p_receiver_device_token text, p_notification jsonb)
 RETURNS TABLE(url text, headers jsonb, body jsonb)
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_url     text;
  v_headers jsonb;
  v_body    jsonb;
begin
  select format('https://fcm.googleapis.com/v1/projects/%s/messages:send', firebase_project_id)
  from secrets into v_url;

  select jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || firebase_access_token)
  from secrets into v_headers;

  select jsonb_build_object('message',
                            jsonb_build_object('token', p_receiver_device_token) || p_notification)
  into
    v_body;

  return query (select v_url url, v_headers headers, v_body body);
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__refresh_firebase_access_token()
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_url text;
  v_headers jsonb;
  v_response_id int;
begin
  select fnc__get_edge_function_url('get-fcm-access-token') into v_url;
  select fnc__get_edge_function_authorization_header() into v_headers;
  select net.http_get(v_url, headers := v_headers) into v_response_id;
  end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__send_push_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_notification         jsonb;
  v_device_tokens        text[];
  v_current_device_token text;
begin
  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_friend_request_notifications = true
      and created_by = new.profile_id
    into v_device_tokens;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_reaction_notifications = true
      and created_by = new.profile_id
    into v_device_tokens;
  elseif new.tagged_in_check_in_id is not null then
    select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_tagged_check_in_notifications = true
      and created_by = new.profile_id
    into v_device_tokens;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
  end if;

  if array_length(v_device_tokens, 1) is null or array_length(v_device_tokens, 1) = 0 then
    return new;
  else
    foreach v_current_device_token in array v_device_tokens
      loop
        perform fnc__post_request(url, headers, body)
        from fnc__get_push_notification_request(v_current_device_token, v_notification);
      end loop;
  end if;


  return new;
end;
$function$
;


