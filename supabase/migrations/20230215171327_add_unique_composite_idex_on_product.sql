CREATE UNIQUE INDEX unique_products ON public.products USING btree (name, description, category_id, sub_brand_id);


