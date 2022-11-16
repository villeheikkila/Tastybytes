alter table "public"."notifications" drop constraint "notifications_tagged_in_check_in_id_fkey";

alter table "public"."notifications" add constraint "check_in_tagged_profile_id" FOREIGN KEY (tagged_in_check_in_id) REFERENCES check_in_tagged_profiles(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "check_in_tagged_profile_id";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_tagged_in_check_in_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_send_notification bool;
begin
  select send_tagged_check_in_notifications into v_send_notification from profile_settings where id = new.profile_id;
  
  if v_send_notification then
      insert into notifications (profile_id, tagged_in_check_in_id) values (new.profile_id, new.id);
  end if;
  
  return new;
end;
$function$
;


