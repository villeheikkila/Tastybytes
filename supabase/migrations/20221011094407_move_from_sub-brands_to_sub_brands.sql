ALTER TABLE "public"."products"
   DROP CONSTRAINT "products_sub-brand_id_fkey";

DROP VIEW csv_export CASCADE;

DROP VIEW IF EXISTS "public"."csv_export";

ALTER TABLE "public"."products"
   DROP COLUMN "sub-brand_id";

ALTER TABLE "public"."products"
   ADD COLUMN "sub_brand_id" bigint NOT NULL;

ALTER TABLE "public"."products"
   ADD CONSTRAINT "products_sub_brands__fk" FOREIGN KEY (sub_brand_id) REFERENCES sub_brands (id) ON DELETE CASCADE NOT valid;

ALTER TABLE "public"."products" validate CONSTRAINT "products_sub_brands__fk";

CREATE OR REPLACE VIEW "public"."csv_export" AS
WITH agg_products AS (
   SELECT
      cat.name AS category,
      string_agg(sc.name, ', '::text ORDER BY sc.name) AS subcategory,
      bo.name AS brand_owner,
      b.name AS brand,
      s.name AS "sub-brand",
      p.name,
      p.id
   FROM ((((((products p
                  LEFT JOIN "sub-brands" s ON ((p.sub_brand_id = s.id)))
               LEFT JOIN brands b ON ((s.brand_id = b.id)))
            LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
         LEFT JOIN categories cat ON ((p.category_id = cat.id)))
      LEFT JOIN products_subcategories ps ON ((ps.product_id = p.id)))
      LEFT JOIN subcategories sc ON ((ps.subcategory_id = sc.id)))
GROUP BY
   cat.name,
   bo.name,
   b.name,
   p.name,
   s.name,
   p.description,
   p.id
)
SELECT
   pr.id,
   ap.category,
   ap.subcategory,
   m.name AS manufacturer,
   ap.brand_owner,
   ap.brand,
   ap. "sub-brand",
   ap.name,
   string_agg(c.review, ', '::text) AS reviews,
   string_agg((((c.rating)::double precision / (2)::double precision))::text, ', '::text) AS ratings,
   pr.username
FROM (((check_ins c
      LEFT JOIN agg_products ap ON ((ap.id = c.product_id)))
   LEFT JOIN companies m ON ((c.manufacturer_id = m.id)))
   LEFT JOIN profiles pr ON ((c.created_by = pr.id)))
GROUP BY
   pr.id,
   pr.username,
   ap.category,
   ap.subcategory,
   m.name,
   ap.brand_owner,
   ap.brand,
   ap. "sub-brand",
   ap.name,
   ap.id;

