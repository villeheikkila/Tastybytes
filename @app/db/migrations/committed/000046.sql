--! Previous: sha1:cbcf7ac6c0b9076fb513da146104ed77ac6646c8
--! Hash: sha1:e56ae50a4d38193c5a2ab1fbcd8982dddf68acec

--! split: 1-current.sql
-- Enter migration here
GRANT INSERT(name) ON TABLE app_public.companies TO tasted_visitor;
