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
  if v_profile_id != auth.uid() then
    insert into notifications (profile_id, check_in_reaction_id) values (v_profile_id, new.id);
  end if;
  return new;
end;
$function$
;


