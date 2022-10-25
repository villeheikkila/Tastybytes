drop trigger if exists "send_notification_on_being_tagged_on_check_in" on "public"."notifications";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_tagged_in_check_in_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into notifications (tagged_in_check_in_id, profile_id) values (new.id, new.profile_id);
end;
$function$
;

CREATE TRIGGER send_notification_on_being_tagged_on_check_in AFTER INSERT ON public.check_in_tagged_profiles FOR EACH ROW EXECUTE FUNCTION tg__send_tagged_in_check_in_notification();


