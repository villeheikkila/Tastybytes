--! Previous: sha1:a098919976e1c6d584f840a7e1bf8c7d09a4a2fa
--! Hash: sha1:be3969fb9059a05b8a1a3e3769dfe0dc33210a1c

-- Enter migration here
ALTER TABLE tasted_public.companies ADD CONSTRAINT company_name_key UNIQUE (name);
