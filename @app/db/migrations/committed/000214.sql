--! Previous: sha1:0d05415777c56fb4b941fe8db31a2089e5de19f1
--! Hash: sha1:432728b0f396d6efff1f987b772cbc0ec4980f47

--! split: 1-current.sql
-- enter migration here
GRANT SELECT,DELETE ON TABLE app_public.check_ins TO tasted_visitor;

create policy delete_own on app_public.check_ins for delete using ((author_id = app_public.current_user_id()));
