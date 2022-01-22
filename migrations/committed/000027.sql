--! Previous: sha1:f1ed6dd0041ccc32d38bb9b7367c786b6f7b7317
--! Hash: sha1:fc4e311717cdefacf93a713fa717fe6e2b3da083

-- Enter migration here
alter table tasted_public.companies alter column name type tasted_public.medium_text;
