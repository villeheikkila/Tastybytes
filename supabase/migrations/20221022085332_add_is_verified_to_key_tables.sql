alter table "public"."companies" add column "is_verified" boolean default false;

alter table "public"."product_variants" add column "is_verified" boolean default false;

alter table "public"."products" add column "is_verified" boolean default false;

alter table "public"."products_subcategories" add column "is_verified" boolean default false;


