set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_category_stats(p_user_id uuid)
 RETURNS TABLE(id bigint, name text, count integer)
 LANGUAGE sql
AS $function$
with unique_products as (select distinct ci.product_id, p.category_id
                         from check_ins ci
                                left join products p on ci.product_id = p.id
                         where ci.created_by = p_user_id
                         group by ci.product_id, p.category_id),
     stats as (select c.id, c.name, count(up.product_id)
               from categories c
                      left join unique_products up on up.category_id = c.id
               group by c.id, c.name)
select *
from stats
where count > 0
order by count desc;
$function$
;


