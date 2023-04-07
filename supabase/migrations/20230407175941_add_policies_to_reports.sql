alter table "public"."reports" enable row level security;

create policy "Enable insert for authenticated users only"
on "public"."reports"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for users with permissions"
on "public"."reports"
as permissive
for select
to authenticated
using (fnc__has_permission(auth.uid(), 'can_read_reports'::text));



