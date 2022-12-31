set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_check_in_reaction_notification(p_check_in_reaction_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_title text;
  v_body  text;
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

  return jsonb_build_object('notification', jsonb_build_object('title', v_title, 'body', v_body));
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_check_in_tag_notification(p_check_in_tag bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
AS $function$
declare
  v_title text;
  v_body  text;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' tagged you in a check-in of ', b.name, case
                                                                             when sb.name is not null
                                                                               then
                                                                               concat(' ', sb.name, ' ')
                                                                             else
                                                                               ' '
    end, pr.name, ' from ', bo.name)
  from check_ins c
         left join profiles p on p.id = c.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where c.id = p_check_in_tag
  into v_body;

  return jsonb_build_object('notification', jsonb_build_object('title', v_title, 'body', v_body));
end;
$function$
;


