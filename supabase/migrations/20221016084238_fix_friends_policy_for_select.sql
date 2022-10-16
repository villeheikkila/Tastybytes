create policy "Enable read access for all users"
on "public"."friends"
as permissive
for select
to public
using (true);



