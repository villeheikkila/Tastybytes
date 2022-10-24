--! Previous: sha1:885bfbd23abed5a2a9a0e32dcdbc50a4773d806f
--! Hash: sha1:a0eb172316a0f9b04f3f8b7db2979c634cd06154

--! split: 1-current.sql
-- Enter migration here
create table app_public.company_likes
(
  id       int references app_public.companies (id) on delete cascade,
  liked_by uuid references app_public.users (id) on delete cascade,
  primary key (id, liked_by)
);
