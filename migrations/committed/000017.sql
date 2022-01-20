--! Previous: sha1:7f86b674ea6b4bd9c922cca0a89cb3ac75d528cd
--! Hash: sha1:cde075ac4e1bbaa955981fc7300cd3cfe97ee390

-- Enter migration here
ALTER TABLE tasted_public.companies ADD CONSTRAINT company_name_key UNIQUE (name);
