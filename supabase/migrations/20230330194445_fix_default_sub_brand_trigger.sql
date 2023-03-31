set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__create_default_sub_brand()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into sub_brands (name, brand_id, created_by, is_verified)
  values (null, new.id, auth.uid(), true);
  return new;
end;
$function$
;


