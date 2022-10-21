drop procedure if exists "public"."fnc__migrate_data"(IN p_created_by text);

drop procedure if exists "public"."fnc__seed_data"();

set check_function_bodies = off;

CREATE OR REPLACE PROCEDURE public.fnc__migrate_data(IN _creator uuid)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
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

  with "unique_sub_brands" as (select distinct b.id brand_id, trim("sub-brand") name
                               from migration_table mt
                                      left join brands b on b.name = trim(mt.brand))
  insert
  into "sub_brands" (name, brand_id, created_by)
  select name, brand_id, _creator created_by
  from "unique_sub_brands"
  on conflict do nothing;

  with all_products as (select mt.flavour     name,
                               mt.description description,
                               sb.id          "sub_brand_id",
                               c.id           category_id,
                               mt.id          migration_id
                        from migration_table mt
                               left join brands b on b.name = trim(mt.brand)
                               left join "sub_brands" sb on (sb.name = trim(mt."sub-brand") or
                                                             (sb.name is null and mt."sub-brand" is null)) and
                                                            b.id = sb.brand_id
                               left join categories c on c.name = trim(mt."category"))
  insert
  into products (name, description, "sub_brand_id", category_id, migration_id,
                 created_by)
  select name,
         description,
         "sub_brand_id",
         category_id,
         migration_id,
         _creator created_by
  from all_products
  on conflict do nothing;

  with all_product_subcategories as (select p.id product_id, sc.id subcategory_id
                                     from migration_table mt
                                            join products p on p.migration_id = mt.id
                                            join categories c on c.id = p.category_id
                                            join subcategories sc
                                                 on sc.name = trim(mt."subcategory") and sc.category_id = c.id)
  insert
  into products_subcategories (product_id, subcategory_id, created_by)
  select product_id, subcategory_id, _creator created_by
  from all_product_subcategories
  on conflict do nothing;


  with all_product_variants as (select p.id product_id, c.id manufacturer_id
                                from migration_table mt
                                       join products p on p.migration_id = mt.id
                                       join companies c on mt.manufacturer = c.name)
  insert
  into product_variants (product_id, manufacturer_id, created_by)
  select product_id, manufacturer_id, _creator created_by
  from all_product_variants
  on conflict do nothing;

  with all_check_ins as (select case
                                  when mt.rating is null then null
                                  else (replace(mt.rating, ',', '.')::numeric * 2) end rating,
                                p.id                                             product_id,
                                mt.id                                            migration_id,
                                pv.id                                            product_variants_id,
                                mt.image                                         image_url,
                                _creator                                         created_by
                         from migration_table mt
                                left join products p on mt.id = p.migration_id
                                left join companies m on mt.manufacturer = m.name
                                left join product_variants pv on m.id = pv.manufacturer_id and pv.product_id = p.id)
  insert
  into check_ins (rating, product_id, migration_id, product_variant_id, image_url, created_by)
  select rating, product_id, migration_id, product_variants_id, image_url, created_by
  from all_check_ins
  on conflict do nothing;
END
$procedure$
;


