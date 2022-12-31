set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__add_user_role()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_role_id bigint;
begin
  select id from roles where name = 'user' into v_role_id;

  insert
  into public.profiles_roles (profile_id, role_id)
  values (new.id, v_role_id);
  return new;
end;
$function$
;

CREATE TRIGGER add_default_role_for_user AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION tg__add_user_role();


