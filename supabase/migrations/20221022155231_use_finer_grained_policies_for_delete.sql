drop policy "Enable delete for admin" on "public"."brands";

drop policy "Enable delete for admin" on "public"."companies";

drop policy "Enable delete for users with can_delete_products permission" on "public"."products";

drop policy "Enable update only for admin" on "public"."products";

drop policy "Allow update only for admin" on "public"."products_subcategories";

drop policy "Enable delete for users with can_delete_products permission" on "public"."products_subcategories";

drop policy "Enable delete only for admin" on "public"."sub_brands";

drop policy "Enable read access for all users" on "public"."roles";

create policy "Enable delete for users with permission"
on "public"."brands"
as permissive
for delete
to public
using (fnc__has_permission(auth.uid(), 'can_delete_brands'::text));


create policy "Enable delete for users with permission"
on "public"."companies"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_companies'::text));


create policy "Enable delete for users with permission"
on "public"."product_variants"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_products'::text));


create policy "Enable delete for users with permission"
on "public"."products"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_products'::text));


create policy "Enable delete for users with permission"
on "public"."products_subcategories"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_products'::text));


create policy "Enable delete for users with permission"
on "public"."sub_brands"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_brands'::text));


create policy "Enable read access for all users"
on "public"."roles"
as permissive
for select
to authenticated
using (true);



