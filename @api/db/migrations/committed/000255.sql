--! Previous: sha1:a529b21e8fce4be4566b138279044c5657c92bbf
--! Hash: sha1:b27269497286afc6a291800f3b472a9631aee699

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE app_public.public_users TO tasted_visitor;
