drop function if exists "public"."fnc__get_product_summary"(p_product_id integer);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_product_summary(p_product_id integer)
 RETURNS TABLE(total_check_ins bigint, average_rating numeric, friend_check_ins bigint, friends_average_rating numeric, current_user_check_ins bigint, current_user_average_rating numeric)
 LANGUAGE plpgsql
AS $function$
declare
  v_friend_ids uuid[] = (select array_agg(case when f.user_id_1 = auth.uid() then f.user_id_2 else f.user_id_1 end)
                         from friends f
                         where f.user_id_1 = auth.uid()
                            or f.user_id_2 = auth.uid());
begin
  return query (select count(ci.id)                                                         total_check_ins,
                       round(avg(ci.rating), 2)                                             average_rating,
                       count(ci.id) filter ( where ci.created_by = ANY (v_friend_ids) )     friend_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = ANY (v_friend_ids) ),
                             2)                                                             friends_average_rating,
                       count(ci.id) filter ( where ci.created_by = auth.uid() )             current_user_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = auth.uid() ), 2) current_user_average_rating
                from products p
                       left join check_ins ci on p.id = ci.product_id
                where p.id = p_product_id);
end ;
$function$
;


