--! Previous: sha1:317ca1218a9608f3e2c3ccc8f6e0135d38a4f170
--! Hash: sha1:ae28a87e40c87be7494b1bc18a6869b4a86310da

--! split: 1-current.sql
-- Enter migration here
grant select on app_public.brands to :DATABASE_VISITOR;
