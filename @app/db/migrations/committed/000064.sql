--! Previous: sha1:372ed6af23d9acd643a4aa8a1f98594101ef5cd1
--! Hash: sha1:3cefbd002282a6f587ac174b8ce083f46817b175

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.brands ADD COLUMN is_verified boolean;
