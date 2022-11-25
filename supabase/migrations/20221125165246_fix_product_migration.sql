set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__merge_products(p_product_id bigint, p_to_product_id bigint)
 RETURNS SETOF products
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__current_user_has_permission('can_merge_products') then
    update check_ins set product_id = p_to_product_id where product_id = p_product_id;
    -- some objects are lost, such as edit suggestions
    delete from products where id = p_product_id;
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__make_id_immutable()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.id := old.id;
  return new;
end;
$function$
;


