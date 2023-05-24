set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__update_notification_badges()
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

  select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
  select array_agg(firebase_registration_token)
  from profile_push_notifications
  where created_by = new.profile_id
  into v_device_tokens;

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
                                                                                                                 fnc__get_badge_count_aps(new.profile_id))))));
      end loop;
  end if;
  return new;
end;
$function$
;

DROP FUNCTION public.fnc__get_badge_count_aps(p_user_id uuid);

CREATE OR REPLACE FUNCTION public.fnc__get_badge_count_aps(p_user_id uuid)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_number_of_unread int;
begin
  select count(1) from notifications where profile_id = p_user_id and seen_at is null into v_number_of_unread;
  return v_number_of_unread;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_check_in_reaction_notification(p_check_in_reaction_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_title       text;
  v_body        text;
  v_check_in_id int;
  v_profile_id  uuid;
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

  select c.id, c.created_by
  from check_in_reactions cir
         left join check_ins c on cir.check_in_id = c.id
  where cir.id = p_check_in_reaction_id
  into v_check_in_id, v_profile_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))));
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_check_in_tag_notification(p_check_in_tag bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_title       text;
  v_body        text;
  v_check_in_id int;
  v_profile_id  uuid;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' tagged you in a check-in of ', b.name, case
                                                                             when sb.name is not null
                                                                               then
                                                                               concat(' ', sb.name, ' ')
                                                                             else
                                                                               ' '
    end, pr.name, ' from ', bo.name)
  from check_in_tagged_profiles ctp
         left join check_ins c on ctp.check_in_id = c.id
         left join profiles p on p.id = c.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where ctp.id = p_check_in_tag
  into v_body;

  select c.id, c.created_by
  from check_in_tagged_profiles ctp
         left join check_ins c on ctp.check_in_id = c.id
  into v_check_in_id, v_profile_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))));
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_friend_request_notification(p_friend_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_title       text;
  v_body        text;
  v_profile_id  uuid;
  v_receiver_id uuid;
begin
  select '' into v_title;
  select p.preferred_name || ' sent you a friend request!'
  from friends f
         left join profiles p on p.id = f.user_id_1
  where f.id = p_friend_id
  into v_body;

  select user_id_1, user_id_2
  from friends f
  where f.id = p_friend_id
  into v_profile_id, v_receiver_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))));
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
  v_notification                    jsonb;
  v_push_notification_device_tokens text[];
  v_current_device_token            text;
begin
  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_friend_request_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_reaction_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  elseif new.tagged_in_check_in_id is not null then
    select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_tagged_check_in_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
  end if;

  if array_length(v_push_notification_device_tokens, 1) is null or
     array_length(v_push_notification_device_tokens, 1) = 0 then
    return new;
  else
    foreach v_current_device_token in array v_push_notification_device_tokens
      loop
        perform fnc__post_request(url, headers, body)
        from fnc__get_push_notification_request(v_current_device_token, v_notification);
      end loop;
  end if;


  return new;
end;
$function$
;

CREATE TRIGGER update_notification_badges AFTER INSERT OR DELETE OR UPDATE ON public.notifications FOR EACH ROW EXECUTE FUNCTION tg__update_notification_badges();


