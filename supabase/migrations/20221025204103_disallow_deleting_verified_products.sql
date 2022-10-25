create policy "Do not allow deleting verified products"
on "public"."products"
as permissive
for delete
to public
using (is_verified);



