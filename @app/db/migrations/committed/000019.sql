--! Previous: sha1:faf8e52c35c4d58571992e00cd625029b4aa8d83
--! Hash: sha1:491a6cdfec97cc4d2695625525ae42a2f624c965

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.check_ins RENAME COLUMN author TO author_id;
