--! Previous: sha1:a54954a512bbbb4690c9eadf3e2d5cdad276f223
--! Hash: sha1:4038f6afe25a674b03f535981e920ff2bcc18a49

-- Enter migration here
alter table tasted_public.products alter column name type tasted_public.medium_text;
