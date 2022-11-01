set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__create_default_sub_brand()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  insert into sub_brands (name, brand_id, created_by)
  values (null, new.id, auth.uid());
  return new;
end;
$function$
;

CREATE TRIGGER create_default_sub_brand AFTER INSERT ON public.brands FOR EACH ROW EXECUTE FUNCTION tg__create_default_sub_brand();


