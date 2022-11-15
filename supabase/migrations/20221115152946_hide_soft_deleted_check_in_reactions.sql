drop policy "Check in reactions are viewable by everyone." on "public"."check_in_reactions";

create policy "Check in reactions are viewable by everyone unless soft-deleted"
on "public"."check_in_reactions"
as permissive
for select
to public
using ((deleted_at IS NULL));



