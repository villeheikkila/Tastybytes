--! Previous: sha1:07c5455a5712cfc821020f6ccbcb99f59984dea7
--! Hash: sha1:4457bc809846b5ea56cc919dba90c3c1825542ef

--! split: 1-current.sql
-- Enter migration here
drop policy create_companies on app_public.companies;

CREATE POLICY create_companies ON app_public.companies
  FOR INSERT
    WITH CHECK ((created_by = app_public.current_user_id ())
    AND created_by IS NOT NULL);
