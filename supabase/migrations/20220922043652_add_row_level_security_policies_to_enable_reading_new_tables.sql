alter table "public"."check_in_flavors" enable row level security;

alter table "public"."check_in_tagged_profiles" enable row level security;

alter table "public"."flavors" enable row level security;

alter table "public"."locations" enable row level security;

alter table "public"."serving_styles" enable row level security;

create policy "Enable read access for all users"
on "public"."check_in_flavors"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."check_in_tagged_profiles"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."flavors"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."locations"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."serving_styles"
as permissive
for select
to public
using (true);



