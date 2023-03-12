create policy "Enable update for users with permission"
on "public"."subcategories"
as permissive
for update
to authenticated
using (fnc__has_permission(auth.uid(), 'can_edit_subcategories'::text));


