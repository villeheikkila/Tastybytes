set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_tagged_in_check_in_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into notifications (profile_id, tagged_in_check_in_id) values (new.check_in_id, new.profile_id);
  return new;
end;
$function$
;


