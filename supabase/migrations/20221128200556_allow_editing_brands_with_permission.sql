create policy "Enable update for users with permission"
on "public"."brands"
as permissive
for update
to public
using (fnc__has_permission(auth.uid(), 'can_edit_brands'::text));



