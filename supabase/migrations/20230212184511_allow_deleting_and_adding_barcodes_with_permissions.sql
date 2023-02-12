drop trigger if exists "on_auth_user_created" on "auth"."users";


drop policy "Enable insert for authenticated users only" on "public"."product_barcodes";

drop policy "Enable read access for all users" on "public"."brand_edit_suggestions";

drop policy "Enable read access for all users" on "public"."brands";

drop policy "Enable update for users with permission" on "public"."brands";

drop policy "Categories are viewable by everyone." on "public"."categories";

drop policy "Enable read access for all users" on "public"."category_serving_styles";

drop policy "Check in comments are viewable by everyone." on "public"."check_in_comments";

drop policy "Enable read access for all users" on "public"."check_in_flavors";

drop policy "Check in reactions are viewable by everyone unless soft-deleted" on "public"."check_in_reactions";

drop policy "Enable read access for all users" on "public"."check_in_tagged_profiles";

drop policy "Companies are viewable by everyone." on "public"."companies";

drop policy "Enable update for users with permission" on "public"."companies";

drop policy "Enable read access for all users" on "public"."company_edit_suggestions";

drop policy "Enable read access for all users" on "public"."countries";

drop policy "Enable read access for all users" on "public"."documents";

drop policy "Enable read access for all users" on "public"."flavors";

drop policy "Enable read access for all users" on "public"."friends";

drop policy "Enable delete for users with permission" on "public"."locations";

drop policy "Enable read access for all users" on "public"."locations";

drop policy "Enable read access for all users" on "public"."product_barcodes";

drop policy "Enable read access for all users" on "public"."product_edit_suggestion_subcategories";

drop policy "Enable read access for all users" on "public"."product_edit_suggestions";

drop policy "Enable read access for all users" on "public"."product_variants";

drop policy "Products are viewable by everyone." on "public"."products";

drop policy "Public profiles are viewable by everyone." on "public"."profiles";

drop policy "Enable read access for all users" on "public"."serving_styles";

drop policy "Enable read access for all users" on "public"."sub_brand_edit_suggestion";

drop policy "Sub-brands are viewable by everyone." on "public"."sub_brands";

drop policy "Subcategories are viewable by everyone." on "public"."subcategories";

create policy "Enable delete for users with permissions"
on "public"."product_barcodes"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_barcodes'::text));


create policy "Enable insert for users with permission"
on "public"."product_barcodes"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_add_barcodes'::text));


create policy "Enable read access for all users"
on "public"."brand_edit_suggestions"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."brands"
as permissive
for select
to authenticated
using (true);


create policy "Enable update for users with permission"
on "public"."brands"
as permissive
for update
to authenticated
using (fnc__has_permission(auth.uid(), 'can_edit_brands'::text));


create policy "Categories are viewable by everyone."
on "public"."categories"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."category_serving_styles"
as permissive
for select
to authenticated
using (true);


create policy "Check in comments are viewable by everyone."
on "public"."check_in_comments"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."check_in_flavors"
as permissive
for select
to authenticated
using (true);


create policy "Check in reactions are viewable by everyone unless soft-deleted"
on "public"."check_in_reactions"
as permissive
for select
to authenticated
using ((deleted_at IS NULL));


create policy "Enable read access for all users"
on "public"."check_in_tagged_profiles"
as permissive
for select
to authenticated
using (true);


create policy "Companies are viewable by everyone."
on "public"."companies"
as permissive
for select
to authenticated
using (true);


create policy "Enable update for users with permission"
on "public"."companies"
as permissive
for update
to authenticated
using (fnc__has_permission(auth.uid(), 'can_edit_companies'::text))
with check (fnc__has_permission(auth.uid(), 'can_edit_companies'::text));


create policy "Enable read access for all users"
on "public"."company_edit_suggestions"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."countries"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."documents"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."flavors"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."friends"
as permissive
for select
to authenticated
using (true);


create policy "Enable delete for users with permission"
on "public"."locations"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_locations'::text));


create policy "Enable read access for all users"
on "public"."locations"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."product_barcodes"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."product_edit_suggestion_subcategories"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."product_edit_suggestions"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."product_variants"
as permissive
for select
to authenticated
using (true);


create policy "Products are viewable by everyone."
on "public"."products"
as permissive
for select
to authenticated
using (true);


create policy "Public profiles are viewable by everyone."
on "public"."profiles"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."serving_styles"
as permissive
for select
to authenticated
using (true);


create policy "Enable read access for all users"
on "public"."sub_brand_edit_suggestion"
as permissive
for select
to authenticated
using (true);


create policy "Sub-brands are viewable by everyone."
on "public"."sub_brands"
as permissive
for select
to authenticated
using (true);


create policy "Subcategories are viewable by everyone."
on "public"."subcategories"
as permissive
for select
to authenticated
using (true);



