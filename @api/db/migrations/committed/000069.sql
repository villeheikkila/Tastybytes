--! Previous: sha1:e697823e3c8178ed1aa4095792b331704066e97f
--! Hash: sha1:a4794b16db9f0b1c90958487d4867b95950e0f6b

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE VIEW public_check_ins AS
SELECT
    id,
    rating,
    review,
    item_id,
    author_id,
    check_in_date,
    location
FROM app_public.check_ins
WHERE is_public IS TRUE;
