drop policy "Enable insert for authenticated users only" on "public"."friends";

create policy "Enable insert for authenticated users only"
on "public"."friends"
as permissive
for insert
to authenticated
with check ((user_id_1 = auth.uid()));



