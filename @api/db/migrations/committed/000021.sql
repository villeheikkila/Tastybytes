--! Previous: sha1:c70eb80be49d2e1d9311883cba9ba511a083f003
--! Hash: sha1:8dee0a658348f67223cc5530a7f5a76bcdff63ec

--! split: 1-current.sql
-- Enter migration here
DROP PROCEDURE migrate_seed;
CREATE OR REPLACE PROCEDURE app_private.migrate_seed () LANGUAGE SQL AS $$
INSERT INTO app_public.companies (name)
SELECT DISTINCT company AS name
FROM app_private.transferable_check_ins ON CONFLICT DO NOTHING;
INSERT INTO app_public.categories (name)
SELECT DISTINCT category AS name
FROM app_private.transferable_check_ins ON CONFLICT DO NOTHING;
WITH types AS (
  SELECT DISTINCT category,
    style AS name
  FROM app_private.transferable_check_ins
)
INSERT INTO app_public.types (name, category)
SELECT name,
  category
FROM types ON CONFLICT DO NOTHING;
WITH items AS (
  SELECT p.brand,
    p.flavor,
    c.id AS manufacturer_id,
    t.id AS type_id
  FROM app_private.transferable_check_ins p
    LEFT JOIN app_public.companies c ON p.company = c.name
    LEFT JOIN app_public.types t ON p.style = t.name
)
INSERT INTO app_public.items (flavor, brand, manufacturer_id, type_id)
SELECT flavor,
  brand,
  manufacturer_id,
  type_id
FROM items ON CONFLICT DO NOTHING;
WITH items AS (
  SELECT CASE
      WHEN LENGTH(p.rating) > 0 THEN (
        REPLACE(p.rating, ',', '.')::DECIMAL * 2
      )::INTEGER
      ELSE NULL
    END AS rating,
    i.id AS item_id
  FROM app_private.transferable_check_ins p
    LEFT JOIN app_public.companies c ON p.company = c.name
    LEFT JOIN app_public.items i ON i.manufacturer_id = c.id
    AND i.brand = p.brand
    AND i.flavor = p.flavor
)
INSERT INTO app_public.check_ins (rating, item_id, author_id)
SELECT rating,
  i.item_id,
  (
    SELECT id
    FROM app_public.users
    WHERE username = 'villeheikkila'
  ) as author_id
FROM items i ON CONFLICT DO NOTHING;
$$;
