--! Previous: sha1:ac5a0da4ce56b71f6ad81b96e767701f48e33082
--! Hash: sha1:1e794cf5589c0af69d820bff829dc7d6c1c6f997

--! split: 1-current.sql
-- Enter migration here
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
WITH brands AS (
  SELECT DISTINCT brand,
    company
  FROM app_private.transferable_check_ins
)
INSERT INTO app_public.brands (name, company_id)
SELECT b.brand as name,
  c.id as company_id
FROM brands b
  LEFT JOIN app_public.companies c ON b.company = c.name ON CONFLICT DO NOTHING;
WITH items AS (
  SELECT b.id as brand_id,
    p.flavor,
    c.id AS manufacturer_id,
    t.id AS type_id
  FROM app_private.transferable_check_ins p
    LEFT JOIN app_public.companies c ON p.company = c.name
    LEFT JOIN app_public.types t ON p.style = t.name
    AND p.category = t.category
    LEFT JOIN app_public.brands b ON p.brand = b.name
    AND b.company_id = c.id
)
INSERT INTO app_public.items (flavor, brand_id, manufacturer_id, type_id)
SELECT flavor,
  brand_id,
  manufacturer_id,
  type_id
FROM items ON CONFLICT DO NOTHING;
WITH check_ins AS (
  SELECT CASE
      WHEN LENGTH(p.rating) > 0 THEN (
        REPLACE(p.rating, ',', '.')::DECIMAL * 2
      )::INTEGER
      ELSE NULL
    END AS rating,
    i.id AS item_id
  FROM app_private.transferable_check_ins p
    LEFT JOIN app_public.companies c ON p.company = c.name
    LEFT JOIN app_public.brands b ON b.company_id = c.id
    AND b.name = p.brand
    LEFT JOIN app_public.categories k ON k.name = p.category
    LEFT JOIN app_public.types t ON t.category = k.name
    AND p.style = t.name
    LEFT JOIN app_public.items i ON i.manufacturer_id = c.id
    AND b.id = i.brand_id
    AND i.flavor = p.flavor
    AND i.type_id = t.id
)
INSERT INTO app_public.check_ins (rating, item_id, author_id)
SELECT rating,
  i.item_id AS item_id,
  (
    SELECT id
    FROM app_public.users
    WHERE username = 'villeheikkila'
  ) AS author_id
FROM check_ins i $$;
