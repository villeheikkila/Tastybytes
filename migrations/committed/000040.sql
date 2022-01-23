--! Previous: sha1:bb4dc39bf7425b6fae894a971ae4d67dbcfe6f31
--! Hash: sha1:f2ca87984d90807043500208dbb0b3f1f0af35a7

-- Enter migration here
ALTER TABLE tasted_public.companies
ADD CONSTRAINT unique_company_name UNIQUE (name);
