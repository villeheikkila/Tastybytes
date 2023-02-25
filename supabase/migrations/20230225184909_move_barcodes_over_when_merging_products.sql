set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__merge_products(p_product_id bigint, p_to_product_id bigint)
 RETURNS SETOF products
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__current_user_has_permission('can_merge_products') then
    alter table products disable trigger check_verification;
    update product_barcodes set product_id = p_to_product_id where product_id = p_product_id;
    update check_ins set product_id = p_to_product_id where product_id = p_product_id;
    -- some objects are lost, such as edit suggestions
    delete from products where id = p_product_id;
    alter table products
      enable trigger check_verification;
  end if;
end;
$function$
;