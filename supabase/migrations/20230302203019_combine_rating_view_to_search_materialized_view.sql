drop function if exists "public"."fnc__search_products_ng"(p_search_term text, p_only_non_checked_in boolean, p_category_name text, p_subcategory_id bigint);

set check_function_bodies = off;

create or replace view "public"."materialized_view__search_product_ratings" as  SELECT p.id,
    p.name,
    p.description,
    p.created_at,
    p.created_by,
    p.category_id,
    p.sub_brand_id,
    p.is_verified,
    to_tsvector(((((COALESCE((b.name)::text, ''::text) || ' '::text) || COALESCE((sb.name)::text, ''::text)) || ' '::text) || COALESCE((p.name)::text, ''::text))) AS search_value,
    count(ci.id) AS total_check_ins,
    round(avg((ci.rating)::numeric), 2) AS average_rating,
    count(ci.id) FILTER (WHERE (ci.created_by IN ( SELECT view__current_user_friends.id
           FROM view__current_user_friends))) AS friends_check_ins,
    round(avg((ci.rating)::numeric) FILTER (WHERE (ci.created_by IN ( SELECT view__current_user_friends.id
           FROM view__current_user_friends))), 2) AS friends_average_rating,
    count(ci.id) FILTER (WHERE (ci.created_by = auth.uid())) AS current_user_check_ins,
    round(avg((ci.rating)::numeric) FILTER (WHERE (ci.created_by = auth.uid())), 2) AS current_user_average_rating,
    count(ci.id) FILTER (WHERE (ci.created_at > (now() - '1 mon'::interval))) AS check_ins_during_previous_month
   FROM (((products p
     LEFT JOIN check_ins ci ON ((p.id = ci.product_id)))
     LEFT JOIN sub_brands sb ON ((sb.id = p.sub_brand_id)))
     LEFT JOIN brands b ON ((sb.brand_id = b.id)))
  GROUP BY p.id, p.name, p.description, p.created_at, p.created_by, p.category_id, p.sub_brand_id, p.is_verified, (to_tsvector(((((COALESCE((b.name)::text, ''::text) || ' '::text) || COALESCE((sb.name)::text, ''::text)) || ' '::text) || COALESCE((p.name)::text, ''::text))));


drop function public.fnc__search_products;

CREATE OR REPLACE FUNCTION public.fnc__search_products(p_search_term text, p_only_non_checked_in boolean, p_category_name text DEFAULT NULL::text, p_subcategory_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF materialized_view__search_product_ratings
 LANGUAGE sql
AS $function$
select pr.*
from materialized_view__search_product_ratings pr
       left join categories cat on pr.category_id = cat.id
       left join products_subcategories psc on psc.product_id = pr.id and psc.subcategory_id = p_subcategory_id
where (p_category_name is null or cat.name = p_category_name)
  and (p_subcategory_id is null or psc.subcategory_id is not null)
  and (p_only_non_checked_in is false or pr.current_user_check_ins = 0)
  and (pr.search_value @@ to_tsquery(replace(p_search_term, ' ', ' & ') || ':*'))
order by ts_rank(search_value, to_tsquery(replace(p_search_term, ' ', ' & ') || ':*')) desc;
$function$
;


