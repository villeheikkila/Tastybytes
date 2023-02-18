set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__search_products(p_search_term text, p_only_non_checked_in boolean, p_category_name text DEFAULT NULL::text, p_subcategory_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF products
 LANGUAGE sql
AS $function$
select p.*
from products p
       left join categories cat on p.category_id = cat.id
       left join "sub_brands" sb on sb.id = p."sub_brand_id"
       left join brands b on sb.brand_id = b.id
       left join companies c on b.brand_owner_id = c.id
where (p_category_name is null or cat.name = p_category_name)
  and (p_subcategory_id is null or sb.id = p_subcategory_id)
  and (p_only_non_checked_in is false or
       p.id not in (select product_id from check_ins where created_by = auth.uid()))
  and (p_search_term % b.name
  or p_search_term % sb.name
  or p_search_term % p.name
  or p_search_term % p.description)
order by ((similarity(p_search_term, b.name) * 2 + similarity(p_search_term, sb.name) +
           similarity(p_search_term, p.name)) + similarity(p_search_term, p.description) / 2) desc;
$function$
;
