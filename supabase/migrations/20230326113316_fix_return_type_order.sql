set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc_get_contributions_by_user(p_uid uuid)
 RETURNS TABLE(products integer, companies integer, brands integer, sub_brands integer, barcodes integer)
 LANGUAGE sql
AS $function$
with c as (select count(id) created_companies
           from companies
           where created_by = p_uid
             and is_verified = true),
     b as (select count(id) created_brands from brands where created_by = p_uid and is_verified = true),
     s as (select count(id) created_sub_brands
           from sub_brands
           where created_by = p_uid
             and is_verified = true),
     p as (select count(id) created_products from products where created_by = p_uid and is_verified = true),
     bc as (select count(id) created_barcodes
            from product_barcodes
            where created_by = p_uid)
select sum(p.created_products)   products,
       sum(c.created_companies)  companies,
       sum(b.created_brands)     brands,
       sum(s.created_sub_brands) sub_brands,
       sum(bc.created_barcodes)  barcodes
from c
       cross join b
       cross join p
       cross join s
       cross join bc;
$function$
;


