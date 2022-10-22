alter table "public"."check_ins" drop constraint "check_ins_migration_id_fkey";

alter table "public"."check_ins" drop constraint "check_ins_migration_id_key";

alter table "public"."migration_table" drop constraint "migration_table_id_key";

alter table "public"."products" drop constraint "products_migration_id_fkey";

alter table "public"."products" drop constraint "products_migration_id_key";

drop procedure if exists "public"."fnc__migrate_data"(IN _creator uuid);

drop view if exists "public"."csv_export";

alter table "public"."migration_table" drop constraint "migration_table_pkey";

drop index if exists "public"."check_ins_migration_id_key";

drop index if exists "public"."migration_table_id_key";

drop index if exists "public"."migration_table_pkey";

drop index if exists "public"."products_migration_id_key";

drop table "public"."migration_table";

alter table "public"."check_ins" drop column "migration_id";

alter table "public"."products" drop column "migration_id";

create or replace view "public"."csv_export" as  WITH agg_products AS (
         SELECT cat.name AS category,
            string_agg(sc.name, ', '::text ORDER BY sc.name) AS subcategory,
            bo.name AS brand_owner,
            b.name AS brand,
            s.name AS sub_brand,
            p.name,
            p.id
           FROM ((((((products p
             LEFT JOIN sub_brands s ON ((p.sub_brand_id = s.id)))
             LEFT JOIN brands b ON ((s.brand_id = b.id)))
             LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
             LEFT JOIN categories cat ON ((p.category_id = cat.id)))
             LEFT JOIN products_subcategories ps ON ((ps.product_id = p.id)))
             LEFT JOIN subcategories sc ON ((ps.subcategory_id = sc.id)))
          GROUP BY cat.name, bo.name, b.name, p.name, s.name, p.description, p.id
        )
 SELECT pr.id,
    ap.category,
    ap.subcategory,
    m.name AS manufacturer,
    ap.brand_owner,
    ap.brand,
    ap.sub_brand,
    ap.name,
    string_agg(c.review, ', '::text) AS reviews,
    string_agg((((c.rating)::double precision / (2)::double precision))::text, ', '::text) AS ratings,
    pr.username
   FROM ((((check_ins c
     LEFT JOIN agg_products ap ON ((ap.id = c.product_id)))
     LEFT JOIN product_variants pv ON ((pv.id = c.product_variant_id)))
     LEFT JOIN companies m ON ((pv.manufacturer_id = m.id)))
     LEFT JOIN profiles pr ON ((c.created_by = pr.id)))
  GROUP BY pr.id, pr.username, ap.category, ap.subcategory, m.name, ap.brand_owner, ap.brand, ap.sub_brand, ap.name, ap.id;



