--! Previous: sha1:a0eb172316a0f9b04f3f8b7db2979c634cd06154
--! Hash: sha1:ae6622011e1c35b0b2db1e6212b366bdc1dd2b03

--! split: 1-current.sql
-- enter migration here
grant select on table app_public.company_likes to tasted_visitor;
create policy select_all on app_public.company_likes for select using (true);

create policy like_company on app_public.company_likes for insert with check (liked_by = app_public.current_user_id());
create policy delete_own on app_public.company_likes for delete using (liked_by = app_public.current_user_id());
create policy moderator_delete on app_public.company_likes for delete using (app_public.current_user_is_privileged());
