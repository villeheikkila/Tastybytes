--! Previous: sha1:b692ecda2c6bf88751f84723b4a4fc32bf854ff8
--! Hash: sha1:6ceb2a9df86b40f5c81398114a3aa8ba64280832

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE ONLY app_public.items
ADD CONSTRAINT itens_brand_id_flavor_key UNIQUE (brand_id, flavor);
