--! Previous: sha1:3902968801f428370a17bcb1f8a6ed822cdb2ace
--! Hash: sha1:d43e6c31368c77a6e1f89ed1511d65db6d7412b9

-- Enter migration here
ALTER TABLE tasted_public.products
ADD CONSTRAINT unique_brand_name_type UNIQUE (name, brand_id, type_id);
