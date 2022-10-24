set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__stamp_created_by()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.created_by = auth.uid();
  new.created_at = (case when TG_OP = 'INSERT' then now() else old.created_at end);
  return new;
end;
$function$
;


