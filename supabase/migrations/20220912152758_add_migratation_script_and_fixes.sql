alter table "public"."brands" alter column "created_at" set default now();

alter table "public"."check_ins" alter column "rating" set data type smallint using "rating"::smallint;

alter table "public"."products" add column "migration_id" numeric;

alter table "public"."subcategories" add column "category_id" bigint not null;

CREATE UNIQUE INDEX brands_brand_owner_id_name_key ON public.brands USING btree (brand_owner_id, name);

CREATE UNIQUE INDEX categories_name_key ON public.categories USING btree (name);

CREATE UNIQUE INDEX products_migration_id_key ON public.products USING btree (migration_id);

CREATE UNIQUE INDEX "products_sub-brand_id_subcategory_id_manufacturer_id_name_d_key" ON public.products USING btree ("sub-brand_id", subcategory_id, manufacturer_id, name, description);

CREATE UNIQUE INDEX "sub-brands_brand_id_name_key" ON public."sub-brands" USING btree (brand_id, name);

CREATE UNIQUE INDEX subcategories_category_id_name_key ON public.subcategories USING btree (category_id, name);

alter table "public"."brands" add constraint "brands_brand_owner_id_name_key" UNIQUE using index "brands_brand_owner_id_name_key";

alter table "public"."categories" add constraint "categories_name_key" UNIQUE using index "categories_name_key";

alter table "public"."products" add constraint "products_migration_id_fkey" FOREIGN KEY (migration_id) REFERENCES migration_table(id) not valid;

alter table "public"."products" validate constraint "products_migration_id_fkey";

alter table "public"."products" add constraint "products_migration_id_key" UNIQUE using index "products_migration_id_key";

alter table "public"."products" add constraint "products_sub-brand_id_subcategory_id_manufacturer_id_name_d_key" UNIQUE using index "products_sub-brand_id_subcategory_id_manufacturer_id_name_d_key";

alter table "public"."sub-brands" add constraint "sub-brands_brand_id_name_key" UNIQUE using index "sub-brands_brand_id_name_key";

alter table "public"."subcategories" add constraint "subcategories_category_id_fkey" FOREIGN KEY (category_id) REFERENCES categories(id) not valid;

alter table "public"."subcategories" validate constraint "subcategories_category_id_fkey";

alter table "public"."subcategories" add constraint "subcategories_category_id_name_key" UNIQUE using index "subcategories_category_id_name_key";

set check_function_bodies = off;

CREATE OR REPLACE PROCEDURE public.migrate_data()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _creator uuid;
BEGIN
    SELECT id from profiles where username = 'villeheikkila' INTO _creator;

    with unique_categorie as (select distinct trim(category) name from migration_table)
    insert
    into categories (name)
    select name
    from unique_categorie
    on conflict do nothing;

    with unique_subcategorie as (select distinct trim(subcategory) name, c.id as category_id
                                 from migration_table mt
                                          left join categories c on c.name = trim(mt.category))
    insert
    into subcategories (name, category_id, created_by)
    select name, category_id, _creator created_by
    from unique_subcategorie
    on conflict do nothing;

    with all_companies as (select brand_owner name
                           from migration_table
                           union
                           select manufacturer name
                           from migration_table),
         unique_companies as (select distinct trim(name) name from all_companies)
    insert
    into companies (name, created_by)
    select name, _creator created_by
    from unique_companies
    on conflict do nothing;

    with unique_brands as (select distinct c.id brand_owner_id, trim(brand) name
                           from migration_table mt
                                    left join companies c on c.name = trim(mt.brand_owner))
    insert
    into brands (name, brand_owner_id, created_by)
    select name, brand_owner_id, _creator created_by
    from unique_brands
    on conflict do nothing;

    with "unique_sub-brands" as (select distinct b.id brand_id, trim("sub-brand") name
                                 from migration_table mt
                                          left join brands b on b.name = trim(mt.brand))
    insert
    into "sub-brands" (name, brand_id, created_by)
    select name, brand_id, _creator created_by
    from "unique_sub-brands"
    on conflict do nothing;

    with all_products as (select mt.flavour     name,
                                 mt.description description,
                                 sb.id          "sub-brand_id",
                                 sc.id          subcategory_id,
                                 m.id           manufacturer_id,
                                 mt.id          migration_id
                          from migration_table mt
                                   left join brands b on b.name = trim(mt.brand)
                                   left join "sub-brands" sb on (sb.name = trim(mt."sub-brand") or
                                                                 (sb.name is null and mt."sub-brand" is null)) and
                                                                b.id = sb.brand_id
                                   left join companies m on m.name = trim(mt.manufacturer)
                                   left join categories c on c.name = trim(mt."category")
                                   left join subcategories sc
                                             on sc.name = trim(mt."subcategory") and sc.category_id = c.id)
    insert
    into products (name, description, "sub-brand_id", subcategory_id, manufacturer_id, migration_id, created_by)
    select name,
           description,
           "sub-brand_id",
           subcategory_id,
           manufacturer_id,
           migration_id,
           _creator created_by
    from all_products
    on conflict do nothing;

    with all_check_ins as (select replace(rating, ',', '.')::decimal * 2 rating, p.id product_id, mt.id migration_id
                           from migration_table mt
                                    left join products p on mt.id = p.migration_id)
    insert
    into check_ins (rating, product_id, migration_id, created_by)
    select rating, product_id, migration_id, _creator created_by
    from all_check_ins
    on conflict do nothing;
END
$procedure$
;

CREATE OR REPLACE PROCEDURE public.migrate_data(IN p_created_by text)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    _creator uuid;
BEGIN
    SELECT id from profiles where username = p_created_by INTO _creator;

    with unique_categorie as (select distinct trim(category) name from migration_table)
    insert
    into categories (name)
    select name
    from unique_categorie
    on conflict do nothing;

    with unique_subcategorie as (select distinct trim(subcategory) name, c.id as category_id
                                 from migration_table mt
                                          left join categories c on c.name = trim(mt.category))
    insert
    into subcategories (name, category_id, created_by)
    select name, category_id, _creator created_by
    from unique_subcategorie
    on conflict do nothing;

    with all_companies as (select brand_owner name
                           from migration_table
                           union
                           select manufacturer name
                           from migration_table),
         unique_companies as (select distinct trim(name) name from all_companies)
    insert
    into companies (name, created_by)
    select name, _creator created_by
    from unique_companies
    on conflict do nothing;

    with unique_brands as (select distinct c.id brand_owner_id, trim(brand) name
                           from migration_table mt
                                    left join companies c on c.name = trim(mt.brand_owner))
    insert
    into brands (name, brand_owner_id, created_by)
    select name, brand_owner_id, _creator created_by
    from unique_brands
    on conflict do nothing;

    with "unique_sub-brands" as (select distinct b.id brand_id, trim("sub-brand") name
                                 from migration_table mt
                                          left join brands b on b.name = trim(mt.brand))
    insert
    into "sub-brands" (name, brand_id, created_by)
    select name, brand_id, _creator created_by
    from "unique_sub-brands"
    on conflict do nothing;

    with all_products as (select mt.flavour     name,
                                 mt.description description,
                                 sb.id          "sub-brand_id",
                                 sc.id          subcategory_id,
                                 m.id           manufacturer_id,
                                 mt.id          migration_id
                          from migration_table mt
                                   left join brands b on b.name = trim(mt.brand)
                                   left join "sub-brands" sb on (sb.name = trim(mt."sub-brand") or
                                                                 (sb.name is null and mt."sub-brand" is null)) and
                                                                b.id = sb.brand_id
                                   left join companies m on m.name = trim(mt.manufacturer)
                                   left join categories c on c.name = trim(mt."category")
                                   left join subcategories sc
                                             on sc.name = trim(mt."subcategory") and sc.category_id = c.id)
    insert
    into products (name, description, "sub-brand_id", subcategory_id, manufacturer_id, migration_id, created_by)
    select name,
           description,
           "sub-brand_id",
           subcategory_id,
           manufacturer_id,
           migration_id,
           _creator created_by
    from all_products
    on conflict do nothing;

    with all_check_ins as (select replace(rating, ',', '.')::decimal * 2 rating, p.id product_id, mt.id migration_id
                           from migration_table mt
                                    left join products p on mt.id = p.migration_id)
    insert
    into check_ins (rating, product_id, migration_id, created_by)
    select rating, product_id, migration_id, _creator created_by
    from all_check_ins
    on conflict do nothing;
END
$procedure$
;

create or replace view "public"."overview" as  SELECT cat.name AS category,
    sc.name AS subcategory,
    m.name AS manufacturer,
    bo.name AS brand_owner,
    b.name AS brand,
    s.name AS "sub-brand",
    p.name,
    p.description,
    ((c.rating)::double precision / (2)::double precision) AS rating,
    cb.username
   FROM ((((((((check_ins c
     LEFT JOIN products p ON ((c.product_id = p.id)))
     LEFT JOIN "sub-brands" s ON ((p."sub-brand_id" = s.id)))
     LEFT JOIN brands b ON ((s.brand_id = b.id)))
     LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
     LEFT JOIN companies m ON ((p.manufacturer_id = m.id)))
     LEFT JOIN subcategories sc ON ((p.subcategory_id = sc.id)))
     LEFT JOIN categories cat ON ((sc.category_id = cat.id)))
     LEFT JOIN profiles cb ON ((c.created_by = cb.id)))
  ORDER BY cat.name, sc.name, bo.name, b.name, p.name;



