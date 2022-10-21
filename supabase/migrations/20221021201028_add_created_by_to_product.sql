set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_product(p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_brand_id bigint, p_sub_brand_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF products
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_product_id   bigint;
  v_sub_brand_id bigint;
BEGIN
  if p_sub_brand_id is null then
    insert into sub_brands (name, brand_id, created_by)
    values (null, p_brand_id, auth.uid())
    returning id into v_sub_brand_id;
  else
    v_sub_brand_id = p_sub_brand_id;
  end if;

  insert into products (name, description, category_id, sub_brand_id, created_by)
  values (p_name, p_description, p_category_id, v_sub_brand_id, auth.uid())
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


