create policy "Enable insert for users with permission"
on "public"."products_subcategories"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_add_subcategories'::text));
