drop policy "Enable insert for authenticated users only" on "public"."brands";

drop policy "Enable insert for authenticated users only" on "public"."check_ins";

drop policy "Enable insert for authenticated users only" on "public"."companies";

drop policy "Enable insert for authenticated users only" on "public"."friends";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_check_in(p_product_id bigint, p_rating numeric DEFAULT NULL::integer, p_review text DEFAULT NULL::text, p_manufacturer_id bigint DEFAULT NULL::bigint, p_serving_style_id bigint DEFAULT NULL::bigint, p_friend_ids uuid[] DEFAULT NULL::uuid[], p_flavor_ids bigint[] DEFAULT NULL::bigint[], p_location_id uuid DEFAULT NULL::uuid)
 RETURNS SETOF check_ins
 LANGUAGE plpgsql
AS $function$
declare
  v_check_in_id        bigint;
  v_product_variant_id bigint;
begin
  if fnc__has_permission(auth.uid(), 'can_create_check_ins') is false then
    raise exception 'user has no access to this feature';
  end if;

  if p_manufacturer_id is not null then
    with existing_product_variant as (select id
                                      from product_variants p
                                      where p.product_id = p_product_id
                                        and p.manufacturer_id = p_manufacturer_id),
         new_product_variant as (
           insert into product_variants (product_id, manufacturer_id)
             select p_product_id, p_manufacturer_id
             where not exists(select 1 from existing_product_variant)
             returning id),
         existing_or_created_id as (select id
                                    from existing_product_variant
                                    union all
                                    select id
                                    from new_product_variant)
    select id
    from existing_or_created_id
    into v_product_variant_id;
  end if;

  insert into check_ins (rating, review, product_id, serving_style_id, product_variant_id, location_id, created_by)
  values (p_rating, p_review, p_product_id, p_serving_style_id, v_product_variant_id, p_location_id, auth.uid())
  returning id into v_check_in_id;

  if p_flavor_ids is not null then
    with flavors_for_check_in as (select v_check_in_id check_in_id, unnest(p_flavor_ids) flavor_id)
    insert
    into check_in_flavors (check_in_id, flavor_id)
    select check_in_id, flavor_id
    from flavors_for_check_in;
  end if;

  if p_friend_ids is not null then
    with tagged_friends as (select v_check_in_id check_in_id, unnest(p_friend_ids) profile_id)
    insert
    into check_in_tagged_profiles (check_in_id, profile_id)
    select check_in_id, profile_id
    from tagged_friends;
  end if;

  return query (select *
                from check_ins
                where id = v_check_in_id);
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__create_check_in_reaction(p_check_in_id bigint)
 RETURNS SETOF check_in_reactions
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
declare
  v_created_check_in_reaction_id bigint;
begin
  if fnc__has_permission(auth.uid(), 'can_react_to_check_ins') is false then
    raise exception 'user has no access to this feature';
  end if;

  select id from check_in_reactions where check_in_id = p_check_in_id and created_by = auth.uid() into v_created_check_in_reaction_id;

  if v_created_check_in_reaction_id is null then
    insert into check_in_reactions (check_in_id, created_by)
    values (p_check_in_id, auth.uid())
    returning id
    into v_created_check_in_reaction_id;
  else
    update check_in_reactions set deleted_at = null where id = v_created_check_in_reaction_id;
  end if;

  return query (select * from check_in_reactions where id = v_created_check_in_reaction_id);
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__create_product(p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_brand_id bigint, p_sub_brand_id bigint DEFAULT NULL::bigint, p_barcode_type text DEFAULT NULL::text, p_barcode_code text DEFAULT NULL::text)
 RETURNS SETOF products
 LANGUAGE plpgsql
AS $function$
declare
  v_product_id   bigint;
  v_sub_brand_id bigint;
begin
  if fnc__has_permission(auth.uid(), 'can_create_products') is false then
    raise exception 'user has no access to this feature';
  end if;

  if p_sub_brand_id is null then
    insert into sub_brands (name, brand_id, created_by)
    values (null, p_brand_id, auth.uid())
    returning id into v_sub_brand_id;
  else
    v_sub_brand_id = p_sub_brand_id;
  end if;

  insert into products (name, description, category_id, sub_brand_id, created_by)
  values (p_name, p_description, p_category_id, v_sub_brand_id, auth.uid())
  returning id into v_product_id;

  with subcategories_for_product as (select unnest(p_sub_category_ids) subcategory_id, v_product_id product_id)
  insert
  into products_subcategories (product_id, subcategory_id, created_by)
  select product_id, subcategory_id, auth.uid() created_by
  from subcategories_for_product;

  if p_barcode_code is not null and p_barcode_type is not null then
    insert into product_barcodes (product_id, barcode, type, created_by)
    values (v_product_id, p_barcode_code, p_barcode_type, auth.uid());
  end if;

  return query (select *
                from products
                where id = v_product_id);
end
$function$
;

create policy "Enable insert for users with permission"
on "public"."brands"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_create_brands'::text));


create policy "Enable insert for users with permissions"
on "public"."check_ins"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_create_check_ins'::text));


create policy "Enable insert for users with permissions"
on "public"."companies"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_create_companies'::text));


create policy "Enable insert for users with permissions"
on "public"."friends"
as permissive
for insert
to authenticated
with check (((user_id_1 = auth.uid()) AND fnc__has_permission(auth.uid(), 'can_send_friend_requests'::text)));



