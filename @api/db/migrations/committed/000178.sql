--! Previous: sha1:e70d2fe5199a86a84d0950bddf8b318b1c84b4c9
--! Hash: sha1:94dea9d15a742c57214f4404fe4d309227e11073

--! split: 1-current.sql
-- Enter migration here
DROP POLICY select_friends_or_public_check_ins ON app_public.check_ins;

CREATE POLICY select_friends_or_public_check_ins ON app_public.check_ins
  FOR SELECT
    USING ((author_id IN (
      SELECT
        app_public.current_user_friends () AS current_user_friends)));
