drop policy "Enable read access for all users" on "public"."product_duplicate_suggestion";

create policy "Enable read access for creator"
on "public"."product_duplicate_suggestion"
as permissive
for select
to authenticated
using ((created_by = auth.uid()));



