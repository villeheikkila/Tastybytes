--! Previous: sha1:21a0e80569576e5bc77f1219b5cca7cb5a442965
--! Hash: sha1:36340a4a60ac12530c2babc0761576f24cd9bea4

--! split: 1-current.sql
-- Enter migration here
revoke insert on app_public.company_likes from tasted_visitor;
