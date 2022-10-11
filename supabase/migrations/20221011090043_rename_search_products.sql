drop function if exists "public"."search_products"(p_search_term text);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__search_products(p_search_term text)
 RETURNS SETOF products
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
select p.*
from products p
         left join "sub-brands" sb on sb.id = p."sub-brand_id"
         left join brands b on sb.brand_id = b.id
         left join companies c on b.brand_owner_id = c.id
WHERE p.name ilike p_search_term
   or p.description ilike p_search_term
   or sb.name ilike p_search_term
   or b.name ilike p_search_term
   or c.name ilike p_search_term;
$function$
;


