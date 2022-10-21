drop policy "Enable insert for authenticated users only" on "public"."products_subcategories";

create policy "Enable insert for authenticated users only"
on "public"."product_variants"
as permissive
for insert
to authenticated
with check ((created_by = auth.uid()));



