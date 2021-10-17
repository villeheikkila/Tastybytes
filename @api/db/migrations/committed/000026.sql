--! Previous: sha1:cb4edf8673227a01fdbaad7f2f81adb4cd697c91
--! Hash: sha1:317ca1218a9608f3e2c3ccc8f6e0135d38a4f170

--! split: 1-current.sql
-- Enter migration here
grant select on app_public.tags to :DATABASE_VISITOR;
