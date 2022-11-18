CREATE UNIQUE INDEX unique_barcode_type_product ON public.product_barcodes USING btree (product_id, barcode, type);

alter table "public"."product_barcodes" add constraint "unique_barcode_type_product" UNIQUE using index "unique_barcode_type_product";


