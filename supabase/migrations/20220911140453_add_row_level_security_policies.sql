alter table "public"."profiles" alter column "username" drop not null;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into public.profiles (id)
  values (new.id);
  return new;
end;
$function$
;

create policy "Brands are viewable by everyone."
on "public"."brands"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."brands"
as permissive
for insert
to authenticated
with check (true);


create policy "Categories are viewable by everyone."
on "public"."categories"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."categories"
as permissive
for insert
to authenticated
with check (true);


create policy "Check in comments are viewable by everyone."
on "public"."check_in_comments"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."check_in_comments"
as permissive
for insert
to authenticated
with check (true);


create policy "Check in reactions are viewable by everyone."
on "public"."check_in_reactions"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."check_in_reactions"
as permissive
for insert
to authenticated
with check (true);


create policy "Check-ins are viewable by everyone."
on "public"."check_ins"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."check_ins"
as permissive
for insert
to authenticated
with check (true);


create policy "Companies are viewable by everyone."
on "public"."companies"
as permissive
for select
to public
using (true);


create policy "Enable insert for authenticated users only"
on "public"."companies"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable insert for authenticated users only"
on "public"."products"
as permissive
for insert
to authenticated
with check (true);


create policy "Products are viewable by everyone."
on "public"."products"
as permissive
for select
to public
using (true);


create policy "Public profiles are viewable by everyone."
on "public"."profiles"
as permissive
for select
to public
using (true);


create policy "Users can delete own profile."
on "public"."profiles"
as permissive
for delete
to public
using ((auth.uid() = id));


create policy "Users can insert their own profile."
on "public"."profiles"
as permissive
for insert
to public
with check ((auth.uid() = id));


create policy "Users can update own profile."
on "public"."profiles"
as permissive
for update
to public
using ((auth.uid() = id));


create policy "Enable insert for authenticated users only"
on "public"."reactions"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."reactions"
as permissive
for select
to public
using (true);


create policy "Sub-brands are viewable by everyone."
on "public"."sub-brands"
as permissive
for select
to public
using (true);


create policy "Subcategories are viewable by everyone."
on "public"."subcategories"
as permissive
for select
to public
using (true);



