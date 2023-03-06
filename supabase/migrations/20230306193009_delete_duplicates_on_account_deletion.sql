alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_created_by_fkey";

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."product_duplicate_suggestion" validate constraint "product_duplicate_suggestion_created_by_fkey";


