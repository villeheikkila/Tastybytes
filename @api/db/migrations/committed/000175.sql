--! Previous: sha1:fa0e2db99098b97440965251d11464a78bbf9e9d
--! Hash: sha1:c05973df2785c5a118c1639362eed117cc8b640a

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.check_ins ENABLE ROW LEVEL SECURITY;
