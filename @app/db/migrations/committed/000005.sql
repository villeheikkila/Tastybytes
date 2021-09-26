--! Previous: sha1:500c1b7f025d023baae0bd2962968c8cbc211053
--! Hash: sha1:6447411fd0a291c9399a5bc8907a0ecb65237147

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.company DISABLE ROW LEVEL SECURITY;
