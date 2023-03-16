drop index if exists "public"."unique_products";

CREATE UNIQUE INDEX unique_products ON public.products USING btree (lower((name)::text), lower((description)::text), category_id, sub_brand_id);


