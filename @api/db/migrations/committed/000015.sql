--! Previous: sha1:d166506353c1c6654a4b3eb73f17e340524544f0
--! Hash: sha1:e07d47d8aac22360827764024b7514e4e6651908

--! split: 1-current.sql
-- Enter migration here
ALTER TABLE app_public.items DROP CONSTRAINT items_flavor_check;
ALTER TABLE app_public.items ADD CONSTRAINT items_flavor_check CHECK (
    (length(flavor) >= 2)
    AND (length(flavor) <= 56)
  );
