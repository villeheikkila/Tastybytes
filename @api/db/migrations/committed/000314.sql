--! Previous: sha1:cd33e5f1f63a039f46502f68fc92029896fb3104
--! Hash: sha1:21a0e80569576e5bc77f1219b5cca7cb5a442965

--! split: 1-current.sql
-- Enter migration here
grant insert (id) on table app_public.company_likes to tasted_visitor;
