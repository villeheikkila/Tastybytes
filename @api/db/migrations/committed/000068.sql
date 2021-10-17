--! Previous: sha1:878eb1da2c2296da887c09f308f3b90d257203f5
--! Hash: sha1:e697823e3c8178ed1aa4095792b331704066e97f

--! split: 1-current.sql
-- Enter migration here
CREATE VIEW app_public.public_check_ins AS
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
