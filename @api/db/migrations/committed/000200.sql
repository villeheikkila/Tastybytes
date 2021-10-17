--! Previous: sha1:3f8ae70b3777b36554a9e78536188bbb2c05c399
--! Hash: sha1:caffd5bff3df111daa2ddb4ea31621e86304363f

--! split: 1-current.sql
-- Enter migration here
drop function app_public.current_user_invited_organization_ids() cascade;
