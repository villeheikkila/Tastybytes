--! Previous: sha1:330c292aa9ca7b846af644f894257d2871f6f837
--! Hash: sha1:fa0e2db99098b97440965251d11464a78bbf9e9d

--! split: 1-current.sql
-- Enter migration here
CREATE POLICY select_friends_or_public_check_ins ON app_public.check_ins FOR SELECT USING (is_public = true or (author_id IN ( SELECT app_public.current_user_friends() AS current_user_friends)));
