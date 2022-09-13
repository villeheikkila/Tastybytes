alter table "public"."products_subcategories" drop constraint "products_subcategories_created_by_fkey";

alter table "public"."brands" alter column "created_by" drop not null;

alter table "public"."companies" alter column "created_by" drop not null;

alter table "public"."products" alter column "created_by" drop not null;

alter table "public"."products_subcategories" alter column "created_by" drop not null;

alter table "public"."sub-brands" alter column "created_by" drop not null;

alter table "public"."subcategories" alter column "created_by" drop not null;

alter table "public"."products_subcategories" add constraint "products_subcategories_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL not valid;

alter table "public"."products_subcategories" validate constraint "products_subcategories_created_by_fkey";


