drop function if exists "public"."fnc__create_product"(p_name text, p_description text, p_category_id bigint, p_sub_brand_id bigint, p_sub_category_ids bigint[]);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_product(p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_sub_brand_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF products
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_product_id bigint;
BEGIN
  insert into products (name, description, category_id, sub_brand_id)
  values (p_name, p_description, p_category_id, p_sub_brand_id)
  returning id into v_product_id;

  with subcategories_for_product as (select unnest(p_sub_category_ids) subcategory_id, v_product_id product_id)
  insert
  into products_subcategories (product_id, subcategory_id, created_by)
  select product_id, subcategory_id, auth.uid() created_by
  from subcategories_for_product;

  return query (select *
                from products
                where id = v_product_id);
END

$function$
;


