drop function if exists "public"."fnc__is_admin"(uid uuid);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__current_user_has_permission(p_permission_name text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
begin
  if fnc__has_permission(auth.uid(), p_permission_name) then
    raise exception 'user has no access to this feature' using errcode = 'unauthorized';
  end if;
  return true;
end ;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__merge_products(p_product_id bigint, p_to_product_id bigint)
 RETURNS SETOF products
 LANGUAGE plpgsql
AS $function$
begin
  if fnc__current_user_has_permission('can_merge_products') then
    update check_ins set product_id = p_to_product_id where id = p_product_id;
    -- some objects are lost, such as edit suggestions
    delete from products where id = p_product_id;
  end if;
end ;
$function$
;


