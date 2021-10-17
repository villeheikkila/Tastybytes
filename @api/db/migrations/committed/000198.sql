--! Previous: sha1:de3615da0c139354f9f0de39d833957dc0ddd50d
--! Hash: sha1:b61a8fd6e211bc0f21f785b7ce856d3403d5a926

--! split: 1-current.sql
-- Enter migration here
drop table app_public.organization_memberships cascade;
drop table app_public.organization_invitations cascade;
