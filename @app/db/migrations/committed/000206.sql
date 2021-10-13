--! Previous: sha1:2117bb6774d852de75aa3ee367bddb73c10719e1
--! Hash: sha1:a1ff1ea8b20292fc7b619126cbe87fc8519ad6a1

--! split: 1-current.sql
-- Enter migration here
create policy select_all on app_public.tags for select using (true);
