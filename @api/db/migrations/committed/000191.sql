--! Previous: sha1:d25dd3f823bb1fba83905b86dcfaadb9fa60fbbc
--! Hash: sha1:9f63dd0e758c1a91e143557c7918665e5dba267b

--! split: 1-current.sql
-- Enter migration here

drop POLICY select_friends_or_public_check_ins on app_public.check_ins;

CREATE POLICY select_friends_or_public_check_ins ON app_public.check_ins FOR SELECT USING ((author_id IN ( SELECT app_public.current_user_friends() AS current_user_friends)));
