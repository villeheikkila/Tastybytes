--! Previous: sha1:e07d47d8aac22360827764024b7514e4e6651908
--! Hash: sha1:a5abbca2d97f536ced87ea7d1f5428c4db4668ed

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.items
  RENAME COLUMN manufacturer TO manufacturer_id;
