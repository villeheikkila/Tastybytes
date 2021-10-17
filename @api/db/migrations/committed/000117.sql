--! Previous: sha1:fbdc44524d2ede4dd690ce2f8138571a5f367a5d
--! Hash: sha1:031e1d23fe547aa8ea8b47c245ac44a2de4d1fdc

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE app_public.public_users TO tasted_visitor;
