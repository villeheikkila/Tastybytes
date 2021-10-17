--! Previous: sha1:36ad057449551ddbeed33661df7ff3cf44537845
--! Hash: sha1:faf8e52c35c4d58571992e00cd625029b4aa8d83

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.items DROP CONSTRAINT items_flavor_check;
ALTER TABLE app_public.items
ADD CONSTRAINT items_flavor_check CHECK (
    (length(flavor) >= 2)
    AND (length(flavor) <= 99)
  );
