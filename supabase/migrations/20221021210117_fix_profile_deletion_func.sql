set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__delete_current_user()
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
delete from auth.users where id = auth.uid();
$function$
;

alter table storage.objects
drop constraint objects_owner_fkey,
add constraint objects_owner_fkey
   foreign key (owner)
   references auth.users(id)
   on delete set null;