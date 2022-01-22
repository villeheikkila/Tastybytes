--! Previous: sha1:be3969fb9059a05b8a1a3e3769dfe0dc33210a1c
--! Hash: sha1:471e04af5edcbeba7d8afbb232f791c47bc7f239

-- Enter migration here
alter table tasted_public.products alter column name type tasted_public.medium_text;
