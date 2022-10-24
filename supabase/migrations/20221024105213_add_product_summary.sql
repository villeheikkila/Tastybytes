set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_product_summary(p_product_id integer)
 RETURNS TABLE(total_check_ins bigint, average_rating numeric, current_user_average_rating numeric)
 LANGUAGE plpgsql
AS $function$
begin
  return query (select count(ci.id)                                                        total_check_ins,
                       round(avg(ci.rating), 2)                                            average_rating,
                       round(avg(ci.rating) filter ( where ci.created_by = auth.uid() ), 2) current_user_average_rating
                from products p
                  left join check_ins ci on p.id = ci.product_id
                where p.id = p_product_id);
end ;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__get_company_summary(p_company_id integer)
 RETURNS TABLE(total_check_ins bigint, average_rating numeric, current_user_average_rating numeric)
 LANGUAGE plpgsql
AS $function$
begin
  return query (select count(ci.id)                                                        total_check_ins,
                       round(avg(ci.rating), 2)                                            average_rating,
                       round(avg(ci.rating) filter ( where ci.created_by = auth.uid() ), 2) current_user_average_rating
                from companies c
                       left join brands b on c.id = b.brand_owner_id
                       left join sub_brands sb on b.id = sb.brand_id
                       left join products p on sb.id = p.sub_brand_id
                       left join check_ins ci on p.id = ci.product_id
                where c.id = p_company_id);
end ;
$function$
;


