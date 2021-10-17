--! Previous: sha1:b61a8fd6e211bc0f21f785b7ce856d3403d5a926
--! Hash: sha1:3f8ae70b3777b36554a9e78536188bbb2c05c399

--! split: 1-current.sql
-- Enter migration here
drop function app_public.delete_organization(uuid);

drop function app_public.create_organization(citext, text);

drop function app_public.accept_invitation_to_organization(uuid, text);

drop function app_public.organization_for_invitation(uuid, text);

drop function app_public.organizations_current_user_is_billing_contact(app_public.organizations);

drop function app_public.organizations_current_user_is_owner(app_public.organizations);

drop function app_public.remove_from_organization(uuid, uuid);

drop function app_public.transfer_organization_billing_contact(uuid, uuid);

drop function app_public.transfer_organization_ownership(uuid, uuid);
