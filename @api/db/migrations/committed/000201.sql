--! Previous: sha1:caffd5bff3df111daa2ddb4ea31621e86304363f
--! Hash: sha1:8411213d3222cedd79845f9345beb237685be712

--! split: 1-current.sql
-- Enter migration here
drop function app_public.invite_to_organization cascade;

drop function tg_users__deletion_organization_checks_and_actions cascade;

drop table app_public.organizations cascade;
