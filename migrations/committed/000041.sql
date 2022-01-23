--! Previous: sha1:f2ca87984d90807043500208dbb0b3f1f0af35a7
--! Hash: sha1:14fb2769f0e89adb549631b6c3ab714d5aeb3d71

-- Enter migration here
alter table tasted_public.products add category varchar(40) references tasted_public.categories(name) on delete cascade;

ALTER TABLE tasted_public.products
ADD CONSTRAINT unique_brand_name_category UNIQUE (name, brand_id, category);
