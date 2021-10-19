--! Previous: sha1:2c90bad581c452d1b5e8d944cabea1373d09fb65
--! Hash: sha1:949a20b6f5ce0bd38e625bb1896b81503dca5c12

--! split: 1-current.sql
-- Enter migration here
drop function app_private.really_create_user(username public.citext, email text, email_is_verified boolean, name text, avatar_url text, password text)
