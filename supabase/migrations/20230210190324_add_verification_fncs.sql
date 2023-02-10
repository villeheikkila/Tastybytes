
set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__verify_brand(p_brand_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  update brands
  set is_verified = true
  where id = p_brand_id;
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__verify_sub_brand(p_sub_brand_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  update sub_brands
  set is_verified = true
  where id = p_sub_brand_id;
end
$function$
;


