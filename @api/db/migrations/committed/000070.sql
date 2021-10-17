--! Previous: sha1:a4794b16db9f0b1c90958487d4867b95950e0f6b
--! Hash: sha1:0e20ce8363dd1cf2e09602ae411aaecc0589fd55

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE VIEW app_public.public_check_ins AS
SELECT
    *
FROM app_public.check_ins
WHERE is_public IS TRUE;
