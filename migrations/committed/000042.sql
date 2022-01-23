--! Previous: sha1:14fb2769f0e89adb549631b6c3ab714d5aeb3d71
--! Hash: sha1:9d54f429d95370417fe1d63a00a387a5f20db190

-- Enter migration here
ALTER TABLE tasted_public.products ALTER COLUMN category SET NOT NULL;
