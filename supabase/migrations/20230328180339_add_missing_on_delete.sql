alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey";

alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_product_id_fkey";

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey" FOREIGN KEY (duplicate_of_product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."product_duplicate_suggestion" validate constraint "product_duplicate_suggestion_duplicate_of_product_id_fkey";

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."product_duplicate_suggestion" validate constraint "product_duplicate_suggestion_product_id_fkey";

create policy "Enable delete for creator"
on "public"."product_duplicate_suggestion"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));



