create policy "Enable delete for users based on user_id"
on "public"."check_in_comments"
as permissive
for delete
to public
using ((auth.uid() = created_by));


create policy "Enable update for creator of comment"
on "public"."check_in_comments"
as permissive
for update
to public
using ((auth.uid() = created_by))
with check ((auth.uid() = created_by));



