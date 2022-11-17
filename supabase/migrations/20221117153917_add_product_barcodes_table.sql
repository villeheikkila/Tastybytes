create sequence "public"."product_barcodes_id_seq";

create table "public"."product_barcodes" (
    "id" bigint not null default nextval('product_barcodes_id_seq'::regclass),
    "product_id" bigint not null,
    "barcode" text not null,
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid
);


alter table "public"."product_barcodes" enable row level security;

alter sequence "public"."product_barcodes_id_seq" owned by "public"."product_barcodes"."id";

CREATE UNIQUE INDEX product_barcodes_pkey ON public.product_barcodes USING btree (id);

alter table "public"."product_barcodes" add constraint "product_barcodes_pkey" PRIMARY KEY using index "product_barcodes_pkey";

alter table "public"."product_barcodes" add constraint "product_barcodes_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL not valid;

alter table "public"."product_barcodes" validate constraint "product_barcodes_created_by_fkey";

alter table "public"."product_barcodes" add constraint "product_barcodes_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."product_barcodes" validate constraint "product_barcodes_product_id_fkey";

create policy "Enable insert for authenticated users only"
on "public"."product_barcodes"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for all users"
on "public"."product_barcodes"
as permissive
for select
to public
using (true);


CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.product_barcodes FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();


