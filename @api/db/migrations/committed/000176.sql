--! Previous: sha1:c05973df2785c5a118c1639362eed117cc8b640a
--! Hash: sha1:05f164f03d2d34c2903d9f2823b8a2babc6aec61

--! split: 1-current.sql
-- Enter migration here
DROP POLICY select_friends_or_public_check_ins on app_public.check_ins;

CREATE POLICY select_friends_or_public_check_ins ON app_public.check_ins
  FOR SELECT
    USING (TRUE);
