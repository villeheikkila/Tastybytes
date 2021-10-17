--! Previous: sha1:9f63dd0e758c1a91e143557c7918665e5dba267b
--! Hash: sha1:a21a3efaf344efd8102e29d9e749e613db9c5cf7

--! split: 1-current.sql
-- Enter migration here
drop POLICY select_friends_or_public_check_ins on app_public.check_ins;
