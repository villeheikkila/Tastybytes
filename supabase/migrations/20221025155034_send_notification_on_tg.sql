alter table "public"."notifications" add column "friend_request_id" bigint;

alter table "public"."notifications" add column "tagged_in_check_in_id" bigint;

alter table "public"."notifications" add constraint "notifications_friend_request_id_fkey" FOREIGN KEY (friend_request_id) REFERENCES friends(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_friend_request_id_fkey";

alter table "public"."notifications" add constraint "notifications_tagged_in_check_in_id_fkey" FOREIGN KEY (tagged_in_check_in_id) REFERENCES check_ins(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_tagged_in_check_in_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_tagged_in_check_in_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into notifications (tagged_in_check_in_id) values (new.id);
end;
$function$
;

CREATE TRIGGER send_notification_on_being_tagged_on_check_in AFTER INSERT ON public.notifications FOR EACH ROW EXECUTE FUNCTION tg__send_tagged_in_check_in_notification();


