set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__clean_up_profile_values()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_trimmed_username   text;
  v_trimmed_first_name text;
  v_trimmed_last_name  text;
begin
  select trim(new.username) into v_trimmed_username;
  select trim(new.first_name) into v_trimmed_first_name;
  select trim(new.last_name) into v_trimmed_last_name;

  if v_trimmed_username = '' then
    new.username = null;
  else
    new.username = v_trimmed_username;
  end if;

  if v_trimmed_first_name = '' then
    new.first_name = null;
  else
    new.first_name = v_trimmed_first_name;
  end if;

  if v_trimmed_last_name = '' then
    new.last_name = null;
  else
    new.last_name = v_trimmed_last_name;
  end if;

  return new;
end;
$function$
;

CREATE TRIGGER clean_up_updates BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION tg__clean_up_profile_values();


