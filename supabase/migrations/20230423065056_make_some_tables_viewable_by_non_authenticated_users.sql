drop policy "Categories are viewable by everyone." on "public"."categories";

drop policy "Enable read access for all users" on "public"."category_serving_styles";

drop policy "Enable read access for all users" on "public"."countries";

drop policy "Enable read access for all users" on "public"."documents";

drop policy "Enable read access for all users" on "public"."flavors";

drop policy "Subcategories are viewable by everyone." on "public"."subcategories";

create policy "Categories are viewable by everyone."
on "public"."categories"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."category_serving_styles"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."countries"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."documents"
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


create policy "Subcategories are viewable by everyone."
on "public"."subcategories"
as permissive
for select
to public
using (true);



