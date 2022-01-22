--! Previous: sha1:471e04af5edcbeba7d8afbb232f791c47bc7f239
--! Hash: sha1:f1ed6dd0041ccc32d38bb9b7367c786b6f7b7317

-- Enter migration here
alter table tasted_public.companies alter column name type tasted_public.medium_text;
