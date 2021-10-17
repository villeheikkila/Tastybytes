--! Previous: sha1:338463cf02a139535068dee752b6d60998ac22d4
--! Hash: sha1:cbcf7ac6c0b9076fb513da146104ed77ac6646c8

--! split: 1-current.sql
-- Enter migration here
REVOKE ALL ON FUNCTION app_public.create_company(name text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.create_company(name text) TO tasted_visitor;
