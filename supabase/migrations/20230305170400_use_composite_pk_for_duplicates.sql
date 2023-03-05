alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_pkey";

drop index if exists "public"."product_duplicate_suggestion_pkey";

alter table "public"."product_duplicate_suggestion" drop column "id";

drop sequence if exists "public"."product_duplicate_suggestion_id_seq";

CREATE UNIQUE INDEX product_duplicate_suggestion_pkey ON public.product_duplicate_suggestion USING btree (product_id, duplicate_of_product_id, created_at);

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_pkey" PRIMARY KEY using index "product_duplicate_suggestion_pkey";


