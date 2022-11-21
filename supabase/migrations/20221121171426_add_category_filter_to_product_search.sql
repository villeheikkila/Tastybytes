drop function if exists "public"."fnc__search_products"(p_search_term text);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__search_products(p_search_term text, p_category_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF products
 LANGUAGE sql
AS $function$
select p.*
from products p
       left join "sub_brands" sb on sb.id = p."sub_brand_id"
       left join brands b on sb.brand_id = b.id
       left join companies c on b.brand_owner_id = c.id
where (p_category_id is null or p.category_id = p_category_id)
  and (p_search_term % b.name
  or p_search_term % sb.name
  or p_search_term % p.name
  or c.name ilike p_search_term)
order by ((similarity(p_search_term, b.name) * 2 + similarity(p_search_term, sb.name) +
           similarity(p_search_term, p.name) * 2 +
           similarity(p_search_term, c.name)) / 2) desc;
$function$
;


