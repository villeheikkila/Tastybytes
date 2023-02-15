drop index if exists "public"."unique_sub_brands_for_non_nulls";

drop index if exists "public"."unique_sub_brands_for_nulls";

CREATE UNIQUE INDEX unique_sub_brands ON public.sub_brands USING btree (name, brand_id, COALESCE((name)::text, ''::text));


