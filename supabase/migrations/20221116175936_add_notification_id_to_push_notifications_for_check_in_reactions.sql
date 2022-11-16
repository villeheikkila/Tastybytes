set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_check_in_reaction_notification(p_check_in_reaction_id bigint, p_notification_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_title text;
  v_body  text;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' reacted to your check-in of ', b.name, ' ', case
                                                                                               when sb.name is not null
                                                                                                 then
                                                                                                 concat(sb.name, ' ')
                                                                                               else
                                                                                                 ''
    end, ' from ', bo.name)
  from check_in_reactions cir
         left join check_ins c on cir.check_in_id = c.id
         left join profiles p on p.id = cir.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where cir.id = p_check_in_reaction_id
  into v_body;

  return jsonb_build_object('notification', jsonb_build_object('title', v_title, 'body', v_body, 'notification_id', p_notification_id));
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__send_push_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_notification jsonb;
begin
  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id, new.id) into v_notification;
  elseif new.tagged_in_check_in_id is not null then
   select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
  end if;

  perform fnc__post_request(url, headers, body)
  from fnc__get_push_notification_request(new.profile_id, v_notification);
  
  return new;
end;
$function$
;


