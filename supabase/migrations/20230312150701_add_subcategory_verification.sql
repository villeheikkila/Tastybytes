CREATE OR REPLACE FUNCTION public.fnc__verify_subcategory(p_subcategory_id bigint, p_is_verified boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table subcategories
    disable trigger check_verification;

  update subcategories
  set is_verified = p_is_verified
  where id = p_subcategory_id;

  alter table subcategories
    enable trigger check_verification;
end
$function$
;