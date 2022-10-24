--! Previous: sha1:c863eb8dcd583ba7e74da1429386db35492a66ff
--! Hash: sha1:3ae87d762f1414db69c35d018d8c0ccf042f3eb6

--! split: 1-current.sql
-- Enter migration here
GRANT SELECT ON TABLE app_public.current_user_friends TO tasted_visitor;
