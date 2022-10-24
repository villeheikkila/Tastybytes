--! Previous: sha1:aa51406d4744d24cffd301aed444e7c0236e8bad
--! Hash: sha1:28ff8a6010c668acb62b7a3875ccea2fe762df03

--! split: 1-current.sql
-- Enter migration here
alter table app_public.companies add column description long_text;
