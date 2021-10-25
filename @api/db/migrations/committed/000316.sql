--! Previous: sha1:36340a4a60ac12530c2babc0761576f24cd9bea4
--! Hash: sha1:90a0ff5f746d14897b41851cf15de16862a12329

--! split: 1-current.sql
-- Enter migration here
revoke insert on app_public.companies from tasted_visitor;
grant insert (id) on table app_public.company_likes to tasted_visitor;
