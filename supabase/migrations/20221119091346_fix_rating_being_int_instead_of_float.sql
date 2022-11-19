drop function if exists "public"."fnc__update_check_in"(p_check_in_id bigint, p_product_id bigint, p_rating integer, p_review text, p_manufacturer_id bigint, p_serving_style_id bigint, p_friend_ids uuid[], p_flavor_ids bigint[], p_location_id uuid);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__update_check_in(p_check_in_id bigint, p_product_id bigint, p_rating numeric DEFAULT NULL::numeric, p_review text DEFAULT NULL::text, p_manufacturer_id bigint DEFAULT NULL::bigint, p_serving_style_id bigint DEFAULT NULL::bigint, p_friend_ids uuid[] DEFAULT NULL::uuid[], p_flavor_ids bigint[] DEFAULT NULL::bigint[], p_location_id uuid DEFAULT NULL::uuid)
 RETURNS SETOF check_ins
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_check_in_created_by uuid;
  v_product_variant_id  bigint;
BEGIN
  select created_by from check_ins where id = p_check_in_id into v_check_in_created_by;

  if v_check_in_created_by != auth.uid() then
    raise exception 'only creator of of the check in can edit it';
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

  update check_ins
  set rating             = p_rating,
      review             = p_review,
      product_id         = p_product_id,
      serving_style_id   = p_serving_style_id,
      product_variant_id = v_product_variant_id,
      location_id = p_location_id
  where id = p_check_in_id
    and created_by = auth.uid();

  delete from check_in_flavors where check_in_id = p_check_in_id;

  if p_flavor_ids is not null then
    with flavors_for_check_in as (select p_check_in_id check_in_id, unnest(p_flavor_ids) flavor_id)
    insert
    into check_in_flavors (check_in_id, flavor_id)
    select check_in_id, flavor_id
    from flavors_for_check_in;
  end if;

  if p_friend_ids is not null then
    with old_tags as (select profile_id id
                      from check_in_tagged_profiles
                      where check_in_id = p_check_in_id),
         new_tags as (select unnest(p_friend_ids) id),
         tags_to_be_removed as (select o.id profile_id
                                from old_tags o
                                       left join new_tags n on o.id = n.id
                                where n.id is null)
    delete
    from check_in_tagged_profiles
    where profile_id in (select profile_id from tags_to_be_removed);

    with tagged_friends as (select p_check_in_id check_in_id, unnest(p_friend_ids) profile_id)
    insert
    into check_in_tagged_profiles (check_in_id, profile_id)
    select check_in_id, profile_id
    from tagged_friends
    on conflict do nothing;
  else
    delete from check_in_tagged_profiles where check_in_id = p_check_in_id;
  end if;

  return query (select *
                from check_ins
                where id = p_check_in_id);
END
$function$
;


