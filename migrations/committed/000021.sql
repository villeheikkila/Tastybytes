--! Previous: sha1:8fd5544dc33aae720d7d9b3a206829d4d2aa5b0e
--! Hash: sha1:db531e8aa5ee41e691a19322c3211fa529466621

-- Enter migration here
alter table tasted_public.users add column first_name tasted_public.short_text;
alter table tasted_public.users add column last_name tasted_public.short_text;
