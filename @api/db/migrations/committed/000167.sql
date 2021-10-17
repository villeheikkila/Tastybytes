--! Previous: sha1:aec05bf949edccbc568360ff8e63a6ed31af4564
--! Hash: sha1:15d9aeeb36d1feb4a587d216c81072ed988beebf

--! split: 1-current.sql
-- Enter migration here
revoke insert on app_public.companies from tasted_visitor;
