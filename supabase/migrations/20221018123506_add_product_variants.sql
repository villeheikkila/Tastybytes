create sequence "public"."product_variants_id_seq";

create table "public"."product_variants" (
    "id" bigint not null default nextval('product_variants_id_seq'::regclass),
    "product_id" bigint,
    "manufacturer_id" bigint
);


alter table "public"."check_ins" add column "product_variant_id" bigint;

alter sequence "public"."product_variants_id_seq" owned by "public"."product_variants"."id";

CREATE UNIQUE INDEX product_variants_pk ON public.product_variants USING btree (id);

CREATE UNIQUE INDEX product_variants_product_id_manufacturer_id_key ON public.product_variants USING btree (product_id, manufacturer_id);

alter table "public"."product_variants" add constraint "product_variants_pk" PRIMARY KEY using index "product_variants_pk";

alter table "public"."check_ins" add constraint "check_ins_product_variant_id_fkey" FOREIGN KEY (product_variant_id) REFERENCES product_variants(id) ON DELETE SET NULL not valid;

alter table "public"."check_ins" validate constraint "check_ins_product_variant_id_fkey";

alter table "public"."product_variants" add constraint "product_variants_manufacturer_id_fkey" FOREIGN KEY (manufacturer_id) REFERENCES companies(id) ON DELETE CASCADE not valid;

alter table "public"."product_variants" validate constraint "product_variants_manufacturer_id_fkey";

alter table "public"."product_variants" add constraint "product_variants_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."product_variants" validate constraint "product_variants_product_id_fkey";

alter table "public"."product_variants" add constraint "product_variants_product_id_manufacturer_id_key" UNIQUE using index "product_variants_product_id_manufacturer_id_key";


