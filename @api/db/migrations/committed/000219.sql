--! Previous: sha1:bc6cee2346c94aafeb56e3b109b4eac7b955f09b
--! Hash: sha1:0e184cb9dd694ef69306bb5cfc20b794f41032fd

--! split: 1-current.sql
-- Enter migration here
GRANT DELETE ON TABLE app_public.items TO tasted_visitor;
GRANT DELETE ON TABLE app_public.companies TO tasted_visitor;
GRANT DELETE ON TABLE app_public.brands TO tasted_visitor;

create policy moderator_delete on app_public.items for delete using (app_public.current_user_is_privileged());
create policy moderator_delete on app_public.companies for delete using (app_public.current_user_is_privileged());
create policy moderator_delete on app_public.brands for delete using (app_public.current_user_is_privileged());
