drop function if exists "public"."fnc__verify_brand"(p_brand_id bigint);

drop function if exists "public"."fnc__verify_product"(p_product_id bigint);

drop function if exists "public"."fnc__verify_sub_brand"(p_sub_brand_id bigint);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__verify_brand(p_brand_id bigint, p_is_verified boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table brands
    disable trigger check_verification;

  update brands
  set is_verified = p_is_verified
  where id = p_brand_id;
  
  alter table brands
    enable trigger check_verification;
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__verify_company(p_company_id bigint, p_is_verified boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table companies
    disable trigger check_verification;

  update companies
  set is_verified = p_is_verified
  where id = p_company_id;

  alter table companies
    enable trigger check_verification;
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__verify_product(p_product_id bigint, p_is_verified boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table products
    disable trigger check_verification;

  update products
  set is_verified = p_is_verified
  where id = p_product_id;

  alter table products
    enable trigger check_verification;
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__verify_sub_brand(p_sub_brand_id bigint, p_is_verified boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table sub_brands
    disable trigger check_verification;

  update sub_brands
  set is_verified = p_is_verified
  where id = p_sub_brand_id;

  alter table sub_brands
    enable trigger check_verification;
end
$function$
;


