drop trigger if exists "make_id_immutable" on "public"."profile_settings";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__use_current_user_profile_id_as_id()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.id := auth.uid();
  return new;
end;
$function$
;

create trigger use_current_user_id_as_id
  before update
  on profile_settings
  for each row
execute procedure tg__use_current_user_profile_id_as_id();

