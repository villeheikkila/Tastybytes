create policy "Enable delete for the owner"
on "public"."notifications"
as permissive
for delete
to public
using ((auth.uid() = profile_id));



