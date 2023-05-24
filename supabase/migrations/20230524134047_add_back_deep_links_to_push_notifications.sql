set check_function_bodies = off;

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
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('checkins', v_check_in_id::text)));
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
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('checkins', v_check_in_id::text)));
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
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('profiles', v_profile_id::text)));
end;
$function$
;


