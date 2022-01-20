--! Previous: sha1:cde075ac4e1bbaa955981fc7300cd3cfe97ee390
--! Hash: sha1:a54954a512bbbb4690c9eadf3e2d5cdad276f223

-- Enter migration here
alter table tasted_public.brands alter column name type tasted_public.medium_text;
