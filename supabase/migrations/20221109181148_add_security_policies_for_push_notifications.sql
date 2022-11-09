alter table "public"."countries" enable row level security;

alter table "public"."profile_push_notification_tokens" enable row level security;

create policy "Enable read access for all users"
on "public"."countries"
as permissive
for select
to public
using (true);



