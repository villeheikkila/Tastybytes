--! Previous: sha1:51e00e3c2305b359f878b71827a1b30398a3a484
--! Hash: sha1:bb4dc39bf7425b6fae894a971ae4d67dbcfe6f31

-- Enter migration here
ALTER TABLE tasted_public.brands
ADD CONSTRAINT unique_company_brand UNIQUE (name, company_id);
