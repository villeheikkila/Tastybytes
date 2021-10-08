--! Previous: sha1:787f20139d572de38624fcecee4822158681a7a5
--! Hash: sha1:a2f8b4ca16f20bd08f580bdbf01bc73423d49f78

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE app_public.public_users TO tasted_visitor;
