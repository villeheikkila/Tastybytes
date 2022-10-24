--! Previous: sha1:432728b0f396d6efff1f987b772cbc0ec4980f47
--! Hash: sha1:0def60c469c3454c91d5946674fd29f947f8b84d

--! split: 1-current.sql
-- Enter migration here
drop function app_public.delete_friend(friend_id uuid);

GRANT SELECT, DELETE ON TABLE app_public.friends TO tasted_visitor;

create policy moderator_delete on app_public.check_ins for delete using (app_public.current_user_is_privileged());
