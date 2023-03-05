create sequence "public"."product_duplicate_suggestion_id_seq";

alter table "public"."product_duplicate_suggestion" drop constraint "product_duplicate_suggestion_pkey";

drop index if exists "public"."product_duplicate_suggestion_pkey";

alter table "public"."product_duplicate_suggestion" add column "id" bigint not null default nextval('product_duplicate_suggestion_id_seq'::regclass);

alter sequence "public"."product_duplicate_suggestion_id_seq" owned by "public"."product_duplicate_suggestion"."id";

CREATE UNIQUE INDEX product_duplicate_suggestion_pkey ON public.product_duplicate_suggestion USING btree (id);

alter table "public"."product_duplicate_suggestion" add constraint "product_duplicate_suggestion_pkey" PRIMARY KEY using index "product_duplicate_suggestion_pkey";


