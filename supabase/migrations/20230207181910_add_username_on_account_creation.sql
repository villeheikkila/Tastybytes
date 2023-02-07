set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__create_profile_for_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
    insert
    into public.profiles (id, username)
    values (new.id, new.raw_user_meta_data ->> 'p_username'::text);
    return new;
end;
$function$
;


create or replace trigger on_auth_user_created
  after insert
  on auth.users
  for each row
execute procedure public.tg__create_profile_for_new_user();