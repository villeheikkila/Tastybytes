set check_function_bodies = off;

CREATE OR REPLACE PROCEDURE public.fnc__create_product(IN p_name text, IN p_description text, IN p_category_id bigint, IN p_sub_brand_id bigint, IN p_sub_category_ids bigint[])
 LANGUAGE plpgsql
AS $procedure$
DECLARE
  v_product_id uuid;
BEGIN
  insert into products (name, description, category_id, sub_brand_id)
  values (p_name, p_description, p_category_id, p_sub_brand_id)
  returning id into v_product_id;
  with subcategories_for_product as (select unnest(p_sub_category_ids) subcategory_id, v_product_id product_id)
  insert
  into products_subcategories (product_id, subcategory_id, created_by)
  select product_id, subcategory_id, auth.uid() created_by
  from subcategories_for_product;
END
$procedure$
;


