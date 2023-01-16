drop function if exists "public"."fnc__edit_product"(p_product_id bigint, p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_sub_brand_id bigint);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__edit_product(p_product_id bigint, p_name text, p_category_id bigint, p_sub_category_ids bigint[], p_sub_brand_id bigint DEFAULT NULL::bigint, p_description text DEFAULT NULL::text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_edit_products') is false then
    raise exception 'user has no access to this feature';
  end if;

  update products
  set name         = p_name,
      description  = p_description,
      category_id  = p_category_id,
      sub_brand_id = p_sub_brand_id
  where id = p_product_id;

  with current_subcategories as (select subcategory_id from products_subcategories where product_id = p_product_id)
  delete
  from products_subcategories ps
  where ps.product_id = p_product_id
    and ps.subcategory_id != any (p_sub_category_ids);

  with subcategories_for_product as (select p_product_id               product_id,
                                            unnest(p_sub_category_ids) subcategory_id)
  insert
  into products_subcategories (product_id, subcategory_id)
  select product_id, subcategory_id
  from subcategories_for_product
  on conflict do nothing;
end
$function$
;


