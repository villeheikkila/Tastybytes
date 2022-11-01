alter table "public"."notifications" add column "check_in_reaction_id" bigint;

alter table "public"."notifications" add constraint "notifications_check_in_reaction_id_fkey" FOREIGN KEY (check_in_reaction_id) REFERENCES check_in_reactions(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_check_in_reaction_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_check_in_reaction_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  declare
    v_profile_id uuid;
begin
    select created_by into v_profile_id from check_ins where id = new.check_in_id;
  insert into notifications (profile_id, check_in_reaction_id) values (v_profile_id, new.id);
  return new;
end;
$function$
;

CREATE TRIGGER send_notification_on_insert AFTER INSERT ON public.check_in_reactions FOR EACH ROW EXECUTE FUNCTION tg__send_check_in_reaction_notification();


