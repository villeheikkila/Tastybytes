--! Previous: sha1:f3e6d27ba114902bf3e6c70fc09e6c30fde673f9
--! Hash: sha1:8c33f3bf739a07ce06e08cfae29bff6a614c07a2

--! split: 1-current.sql
-- Enter migration here
grant select on app_public.tags to :DATABASE_VISITOR;
