alter table "public"."products_subcategories" drop constraint "products_subcategories_product_id_fkey";

alter table "public"."products_subcategories" drop constraint "products_subcategories_subcategory_id_fkey";

alter table "public"."companies" alter column "name" set not null;

CREATE UNIQUE INDEX companies_name_key ON public.companies USING btree (name);

alter table "public"."companies" add constraint "companies_name_key" UNIQUE using index "companies_name_key";

alter table "public"."products_subcategories" add constraint "products_subcategories_product_id_fkey" FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE not valid;

alter table "public"."products_subcategories" validate constraint "products_subcategories_product_id_fkey";

alter table "public"."products_subcategories" add constraint "products_subcategories_subcategory_id_fkey" FOREIGN KEY (subcategory_id) REFERENCES subcategories(id) ON DELETE CASCADE not valid;

alter table "public"."products_subcategories" validate constraint "products_subcategories_subcategory_id_fkey";

set check_function_bodies = off;

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
                                 c.id           category_id,
                                 m.id           manufacturer_id,
                                 mt.id    migration_id
                          from migration_table mt
                                   left join brands b on b.name = trim(mt.brand)
                                   left join "sub-brands" sb on (sb.name = trim(mt."sub-brand") or
                                                                 (sb.name is null and mt."sub-brand" is null)) and
                                                                b.id = sb.brand_id
                                   left join companies m on m.name = trim(mt.manufacturer)
                                   left join categories c on c.name = trim(mt."category"))
    insert
    into products (name, description, "sub-brand_id", category_id, manufacturer_id, migration_id,
                   created_by)
    select name,
           description,
           "sub-brand_id",
           category_id,
           manufacturer_id,
           migration_id,
           _creator created_by
    from all_products
    on conflict do nothing;

    with all_product_subcategories as (select p.id product_id, sc.id subcategory_id
                                       from migration_table mt
                                                left join products p on p.migration_id = mt.id
                                                left join categories c on c.id = p.category_id
                                                left join subcategories sc
                                                          on sc.name = trim(mt."subcategory") and sc.category_id = c.id)
    insert
    into products_subcategories (product_id, subcategory_id, created_by)
    select product_id, subcategory_id, _creator created_by
    from all_product_subcategories
    on conflict do nothing;

    with all_check_ins as (select case
                                      when mt.rating is null then null
                                      else replace(mt.rating, ',', '.')::decimal * 2 end rating,
                                  p.id                                                   product_id,
                                  mt.id                                                  migration_id
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


