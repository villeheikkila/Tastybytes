alter table "public"."documents" enable row level security;

create policy "Enable read access for all users"
on "public"."documents"
as permissive
for select
to public
using (true);

