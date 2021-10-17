--! Previous: sha1:35a6887a334bf1bb96b5a265a168feb1f9afdba8
--! Hash: sha1:631b1a7b15e78595b87d4e2efbfeed6a3667ae01

--! split: 1-current.sql
-- Enter migration here

grant select on app_public.public_users  to :DATABASE_VISITOR;
grant select on app_public.activity_feed to :DATABASE_VISITOR;
