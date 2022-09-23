create extension if not exists "citext" with schema "public" version '1.6';

create type "public"."reactions" as enum ('toast', 'like', 'dislike', 'love', 'hate');

drop policy "Enable read access for all users" on "public"."reactions";

alter table "public"."check_in_reactions" drop constraint "check_in_reactions_reaction_id_fkey";

alter table "public"."products" drop constraint "products_manufacturer_id_fkey";

alter table "public"."products" drop constraint "unique_name_description_joins";

alter table "public"."reactions" drop constraint "reactions_name_key";

drop view if exists "public"."csv_export";

alter table "public"."reactions" drop constraint "reactions_pkey";

drop index if exists "public"."reactions_name_key";

drop index if exists "public"."reactions_pkey";

drop index if exists "public"."unique_name_description_joins";

drop table "public"."reactions";

alter table "public"."check_in_reactions" drop column "reaction_id";

alter table "public"."check_in_reactions" add column "reaction" reactions not null;

alter table "public"."check_ins" alter column "rating" set data type rating using "rating"::rating;

alter table "public"."products" drop column "manufacturer_id";

alter table "public"."profiles" add constraint "check_username" CHECK (((length(username) >= 2) AND (length(username) <= 24) AND (username ~ ('^[a-zA-Z]([_.]?[a-zA-Z0-9])+$'::citext)::text))) not valid;

alter table "public"."profiles" validate constraint "check_username";

create or replace view "public"."csv_export" as  WITH agg_products AS (
         SELECT cat.name AS category,
            string_agg(sc.name, ', '::text ORDER BY sc.name) AS subcategory,
            bo.name AS brand_owner,
            b.name AS brand,
            s.name AS "sub-brand",
            p.name,
            p.id
           FROM ((((((products p
             LEFT JOIN "sub-brands" s ON ((p."sub-brand_id" = s.id)))
             LEFT JOIN brands b ON ((s.brand_id = b.id)))
             LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
             LEFT JOIN categories cat ON ((p.category_id = cat.id)))
             LEFT JOIN products_subcategories ps ON ((ps.product_id = p.id)))
             LEFT JOIN subcategories sc ON ((ps.subcategory_id = sc.id)))
          GROUP BY cat.name, bo.name, b.name, p.name, s.name, p.description, p.id
        )
 SELECT ap.category,
    ap.subcategory,
    m.name AS manufacturer,
    ap.brand_owner,
    ap.brand,
    ap."sub-brand",
    ap.name,
    ap.id,
    string_agg(c.review, ', '::text) AS reviews,
    string_agg((c.rating)::text, ', '::text) AS ratings,
    pr.username
   FROM (((check_ins c
     LEFT JOIN agg_products ap ON ((ap.id = c.product_id)))
     LEFT JOIN companies m ON ((c.manufacturer_id = m.id)))
     LEFT JOIN profiles pr ON ((c.created_by = pr.id)))
  GROUP BY pr.username, ap.category, ap.subcategory, m.name, ap.brand_owner, ap.brand, ap."sub-brand", ap.name, ap.id;



