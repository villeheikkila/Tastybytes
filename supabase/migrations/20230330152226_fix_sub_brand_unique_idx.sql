drop index if exists "public"."unique_sub_brands";

CREATE UNIQUE INDEX unique_sub_brands_where_null ON public.sub_brands USING btree (brand_id) WHERE (name IS NULL);

CREATE UNIQUE INDEX unique_sub_brands ON public.sub_brands USING btree (name, brand_id) WHERE (name IS NOT NULL);


