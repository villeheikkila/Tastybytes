--! Previous: sha1:8411213d3222cedd79845f9345beb237685be712
--! Hash: sha1:f75281014b06a756e46901d8490e51ed8ba2ca65

--! split: 1-current.sql
-- Enter migration here
drop function app_public.current_user_member_organization_ids() cascade;
