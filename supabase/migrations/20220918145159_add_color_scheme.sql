create type enum__color_scheme as enum ('light', 'dark', 'system');

alter table "public"."friends" enable row level security;

alter table "public"."migration_table" enable row level security;

alter table "public"."profiles" add column "color_scheme" enum__color_scheme not null default 'system'::enum__color_scheme;

create policy "Enable read access for all users"
on "public"."friends"
as permissive
for select
to public
using (true);



