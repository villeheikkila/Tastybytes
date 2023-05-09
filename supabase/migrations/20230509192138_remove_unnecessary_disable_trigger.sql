set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__merge_locations(p_location_id uuid, p_to_location_id uuid)
 RETURNS SETOF products
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  if fnc__current_user_has_permission('can_merge_locations') then
    update check_ins set location_id = p_to_location_id where location_id = purchase_location_id;
    delete from locations where id = p_location_id;
  end if;
end;
$function$
;


