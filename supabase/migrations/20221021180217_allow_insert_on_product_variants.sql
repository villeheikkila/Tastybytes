create policy "Enable insert for authenticated users"
on "public"."products_subcategories"
as permissive
for insert
to authenticated
with check ((created_by = auth.uid()));



