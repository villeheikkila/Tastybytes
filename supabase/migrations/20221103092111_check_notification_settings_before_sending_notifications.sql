set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__send_check_in_reaction_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_profile_id        uuid;
  v_send_notification bool;
begin
  select created_by into v_profile_id from check_ins where id = new.check_in_id;
  select send_reaction_notifications into v_send_notification from profile_settings where id = v_profile_id;

  if v_profile_id != auth.uid() and v_send_notification then
    insert into notifications (profile_id, check_in_reaction_id) values (v_profile_id, new.id);
  end if;
  
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__send_friend_request_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare 
  v_send_notification bool;
begin
  select send_friend_request_notifications into v_send_notification from profile_settings where id = new.user_id_2;

  if v_send_notification then
      insert into notifications (profile_id, friend_request_id) values (new.user_id_2, new.id);
  end if;

  return new;
end;
$function$
;

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
      insert into notifications (profile_id, tagged_in_check_in_id) values (new.profile_id, new.check_in_id);
  end if;
  
  return new;
end;
$function$
;


