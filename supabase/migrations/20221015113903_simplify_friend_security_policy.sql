drop policy "Enable update for both sides of friend status unless blocked" on "public"."friends";

create policy "Enable update for both sides of friend status "
on "public"."friends"
as permissive
for update
to public
using (((user_id_1 = auth.uid()) OR (user_id_2 = auth.uid())))
with check (((user_id_1 = auth.uid()) OR (user_id_2 = auth.uid())));



