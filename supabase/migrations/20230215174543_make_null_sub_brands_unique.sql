CREATE UNIQUE INDEX unique_sub_brands_for_non_nulls ON public.sub_brands USING btree (name, brand_id) WHERE (name IS NOT NULL);

CREATE UNIQUE INDEX unique_sub_brands_for_nulls ON public.sub_brands USING btree (name, brand_id) WHERE (name IS NULL);


