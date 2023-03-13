create policy "Enable delete for users with permission"
on "public"."serving_styles"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_serving_styles'::text));


create policy "Enable insert for users with permission"
on "public"."serving_styles"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_add_serving_styles'::text));


create policy "Enable update for users with permission"
on "public"."serving_styles"
as permissive
for update
to authenticated
using (fnc__has_permission(auth.uid(), 'can_edit_serving_styles'::text));



