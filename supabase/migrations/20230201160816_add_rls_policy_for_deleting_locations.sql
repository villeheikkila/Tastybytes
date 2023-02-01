set check_function_bodies = off;

create policy "Enable delete for users with permission"
on "public"."locations"
as permissive
for delete
to public
using (fnc__has_permission(auth.uid(), 'can_delete_locations'::text));



