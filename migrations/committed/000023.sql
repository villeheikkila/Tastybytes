--! Previous: sha1:54672d5cbe58ffbf95bd7bd32d275606f6fb279b
--! Hash: sha1:a098919976e1c6d584f840a7e1bf8c7d09a4a2fa

-- Enter migration here
alter table tasted_public.users drop column name;

alter table tasted_public.companies add column name tasted_public.short_text;
