--! Previous: sha1:4038f6afe25a674b03f535981e920ff2bcc18a49
--! Hash: sha1:8fd5544dc33aae720d7d9b3a206829d4d2aa5b0e

-- Enter migration here
alter table tasted_public.companies drop column first_name;
alter table tasted_public.companies drop column last_name;
