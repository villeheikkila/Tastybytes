set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_friend_request_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into notifications (profile_id, friend_request_id) values (new.user_id_2, new.id);
  return new;
end;
$function$
;

CREATE TRIGGER send_notification_on_insert AFTER INSERT ON public.friends FOR EACH ROW EXECUTE FUNCTION tg__send_friend_request_notification();


