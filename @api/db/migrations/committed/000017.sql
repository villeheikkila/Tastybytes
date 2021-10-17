--! Previous: sha1:a5abbca2d97f536ced87ea7d1f5428c4db4668ed
--! Hash: sha1:36ad057449551ddbeed33661df7ff3cf44537845

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.items DROP CONSTRAINT items_brand_check;
ALTER TABLE app_public.items
ADD CONSTRAINT items_brand_check CHECK (
    (length(brand) >= 2)
    AND (length(brand) <= 56)
  );
