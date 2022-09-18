create type "public"."color_scheme" as enum ('light', 'dark', 'system');

alter table "public"."friends" enable row level security;

alter table "public"."migration_table" enable row level security;

alter table "public"."profiles" add column "color_scheme" color_scheme not null default 'system'::color_scheme;

create policy "Enable read access for all users"
on "public"."friends"
as permissive
for select
to public
using (true);



