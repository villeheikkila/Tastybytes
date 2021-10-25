--! Previous: sha1:ae6622011e1c35b0b2db1e6212b366bdc1dd2b03
--! Hash: sha1:cd33e5f1f63a039f46502f68fc92029896fb3104

--! split: 1-current.sql
-- enter migration here
grant insert (id) on table app_public.companies to tasted_visitor;
