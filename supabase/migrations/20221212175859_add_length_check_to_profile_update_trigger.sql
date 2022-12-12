set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__clean_up_profile_values()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if coalesce(trim(new.username), '') = '' then
    new.username := null;
  else
    new.username := trim(new.username);
  end if;

  if coalesce(trim(new.first_name), '') = '' then
    new.first_name := null;
  else
    if length(trim(new.first_name)) > 32 then
      raise E'First name is too long, length must be under 32 characters.';
    end if;
    
    new.first_name := trim(new.first_name);
  end if;

  if coalesce(trim(new.last_name), '') = '' then
    new.last_name := null;
  else
    if length(trim(new.first_name)) > 32 then
      raise E'Last name is too long, length must be under 32 characters.';
    end if;

    new.last_name := trim(new.last_name);
  end if;

  return new;
end;
$function$
;


