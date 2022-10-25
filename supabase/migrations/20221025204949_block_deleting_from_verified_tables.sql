alter table "public"."brands" add column "is_verified" boolean not null default false;

create policy "Do not allow deleting verified"
on "public"."brands"
as restrictive
for delete
to public
using (is_verified);


create policy "Do not allow deleting verified"
on "public"."companies"
as restrictive
for delete
to public
using (is_verified);


create policy "Do not allow deleting verified"
on "public"."product_variants"
as restrictive
for delete
to public
using (is_verified);


create policy "Do not allow deleting verified"
on "public"."products_subcategories"
as restrictive
for delete
to public
using (is_verified);


create policy "Do not allow deleting verified"
on "public"."sub_brands"
as restrictive
for delete
to public
using (is_verified);


create policy "Do not allow deleting verified"
on "public"."subcategories"
as restrictive
for delete
to public
using (is_verified);



