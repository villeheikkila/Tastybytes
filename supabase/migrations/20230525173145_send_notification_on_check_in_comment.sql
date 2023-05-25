alter table "public"."notifications" add column "check_in_comment_id" bigint;

alter table "public"."profile_push_notifications" add column "send_comment_notifications" boolean default false;

alter table "public"."profile_settings" add column "send_comment_notifications" boolean default true;

alter table "public"."notifications" add constraint "notifications_check_in_comment_id_fkey" FOREIGN KEY (check_in_comment_id) REFERENCES check_in_comments(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_check_in_comment_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_comment_notification(p_check_in_comment_id bigint)
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
  select concat(p2.preferred_name, ' commented on your check-in of ', b.name, case
                                                                             when sb.name is not null
                                                                               then
                                                                               concat(' ', sb.name, ' ')
                                                                             else
                                                                               ' '
    end, pr.name, ' from ', bo.name)
  from check_in_comments cic
         left join profiles p2 on cic.created_by = p2.id
         left join check_ins c on cic.check_in_id = c.id
         left join profiles p on p.id = c.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where cic.id = p_check_in_comment_id
  into v_body;

  select c.id, c.created_by
  from check_in_tagged_profiles ctp
         left join check_ins c on ctp.check_in_id = c.id
  into v_check_in_id, v_profile_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('checkins', v_check_in_id::text)));
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__send_check_in_comment_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_send_notification bool;
begin
  select send_comment_notifications into v_send_notification from profile_settings where id = new.profile_id;

  if v_send_notification then
      insert into notifications (profile_id, check_in_comment_id) values (new.profile_id, new.id);
  end if;

  return new;
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
  elseif new.check_in_comment_id is not null then
    select fnc__get_comment_notification(new.check_in_comment_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_comment_notifications = true
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

CREATE TRIGGER send_notification_on_insert AFTER INSERT ON public.check_in_comments FOR EACH ROW EXECUTE FUNCTION tg__send_check_in_comment_notification();


