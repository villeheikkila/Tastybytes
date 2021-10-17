--! Previous: sha1:05f164f03d2d34c2903d9f2823b8a2babc6aec61
--! Hash: sha1:e70d2fe5199a86a84d0950bddf8b318b1c84b4c9

--! split: 1-current.sql
-- Enter migration here
DROP POLICY select_friends_or_public_check_ins on app_public.check_ins;

CREATE POLICY select_friends_or_public_check_ins ON app_public.check_ins FOR SELECT USING (is_public = true or (author_id IN ( SELECT app_public.current_user_friends() AS current_user_friends)));
