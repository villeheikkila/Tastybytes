set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_product(p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_brand_id bigint, p_sub_brand_id bigint DEFAULT NULL::bigint, p_barcode_type text DEFAULT NULL::text, p_barcode_code text DEFAULT NULL::text)
 RETURNS SETOF products
 LANGUAGE plpgsql
AS $function$
declare
  v_product_id   bigint;
  v_sub_brand_id bigint;
begin
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

  if p_barcode_code is not null and p_barcode_type is not null then
    insert into product_barcodes (product_id, barcode, type, created_by)
    values (v_product_id, p_barcode_code, p_barcode_type, auth.uid());
  end if;

  return query (select *
                from products
                where id = v_product_id);
end
$function$
;


