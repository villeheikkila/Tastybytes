--! Previous: sha1:b27269497286afc6a291800f3b472a9631aee699
--! Hash: sha1:c4620cc42633200284eecd657b47d363f3b2a5d1

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE app_public.current_user_friends TO tasted_visitor;
