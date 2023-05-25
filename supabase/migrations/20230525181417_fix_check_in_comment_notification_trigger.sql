set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_check_in_comment_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_send_notification bool;
begin
  select send_comment_notifications into v_send_notification from profile_settings where id = new.created_by;

  if v_send_notification then
      insert into notifications (profile_id, check_in_comment_id) values (new.created_by, new.id);
  end if;

  return new;
end;
$function$
;


