create extension if not exists "pg_trgm" with schema "public" version '1.6';

CREATE INDEX brand_name_idx ON public.products USING gist (COALESCE(name, description) gist_trgm_ops);

CREATE INDEX product_description_idx ON public.products USING gist (description gist_trgm_ops);

CREATE INDEX product_name_idx ON public.products USING gist (name gist_trgm_ops);

CREATE INDEX "sub-brand_name_idx" ON public."sub-brands" USING gist (name gist_trgm_ops);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.search_products(p_search_term text)
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


