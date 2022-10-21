alter table "public"."products" drop constraint "products_category_id_fkey";

alter table "public"."products" add constraint "products_category_id_fkey" FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE not valid;

alter table "public"."products" validate constraint "products_category_id_fkey";


