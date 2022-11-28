

create policy "Enable update for users with permission"
on "public"."companies"
as permissive
for update
to public
using (fnc__has_permission(auth.uid(), 'can_edit_companies'::text))
with check (fnc__has_permission(auth.uid(), 'can_edit_companies'::text));



