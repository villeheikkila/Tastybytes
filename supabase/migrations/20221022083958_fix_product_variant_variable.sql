set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_check_in(p_product_id bigint, p_rating integer DEFAULT NULL::integer, p_review text DEFAULT NULL::text, p_manufacturer_id bigint DEFAULT NULL::bigint, p_serving_style_id bigint DEFAULT NULL::bigint, p_friend_ids uuid[] DEFAULT NULL::uuid[], p_flavor_ids bigint[] DEFAULT NULL::bigint[])
 RETURNS SETOF check_ins
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_check_in_id        bigint;
  v_product_variant_id bigint;
BEGIN
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

  insert into check_ins (rating, review, product_id, serving_style_id, product_variant_id, created_by)
  values (p_rating, p_review, p_product_id, p_serving_style_id, v_product_variant_id, auth.uid())
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
END
$function$
;


