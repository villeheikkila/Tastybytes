--! Previous: sha1:a6223bc2555e77f1d9c4570124b19919cb3bb866
--! Hash: sha1:7e0bd7374fcac1dbef4435a423b2e3198340a63b

--! split: 1-current.sql
-- Enter migration here
GRANT DELETE ON TABLE app_public.tags TO tasted_visitor;

create policy moderator_delete on app_public.tags for delete using (app_public.current_user_is_privileged());
