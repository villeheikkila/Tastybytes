create domain domain__rating as numeric
  constraint rating_value_check check ((VALUE >= (0)::numeric) AND (VALUE <= (5)::numeric));
  
drop function if exists "public"."fnc__create_check_in"(p_product_id bigint, p_rating integer, p_review text, p_manufacturer_id bigint, p_serving_style_id bigint, p_friend_ids uuid[], p_flavor_ids bigint[]);

alter table "public"."check_ins" alter column "rating" set data type domain__rating using "rating"::domain__rating;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__create_check_in(p_product_id bigint, p_rating numeric DEFAULT NULL::integer, p_review text DEFAULT NULL::text, p_manufacturer_id bigint DEFAULT NULL::bigint, p_serving_style_id bigint DEFAULT NULL::bigint, p_friend_ids uuid[] DEFAULT NULL::uuid[], p_flavor_ids bigint[] DEFAULT NULL::bigint[])
 RETURNS SETOF check_ins
 LANGUAGE plpgsql
AS $function$
DECLARE
  v_check_in_id        bigint;
  v_product_variant_id bigint;
  v_rating decimal;
BEGIN
  -- rating of zero is considered as null to keep things as simple as possible, minimum rating is 0.25/0.5
  if p_rating = 0 then
    v_rating = null;
  else 
    v_rating = p_rating;
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

CREATE OR REPLACE FUNCTION public.fnc__get_profile_summary(p_uid uuid)
 RETURNS TABLE(total_check_ins bigint, unique_check_ins bigint, average_rating numeric, unrated bigint, rating_0 bigint, rating_1 bigint, rating_2 bigint, rating_3 bigint, rating_4 bigint, rating_5 bigint, rating_6 bigint, rating_7 bigint, rating_8 bigint, rating_9 bigint, rating_10 bigint)
 LANGUAGE plpgsql
AS $function$
begin
  return query (select count(1)                                 total_check_ins,
                       count(distinct product_id)               unique_check_ins,
                       round(avg(rating), 2)                    average_rating,
                       count(1) filter ( where rating is null ) unrated,
                       count(1) filter ( where rating = 0.5 )     rating_1,
                       count(1) filter ( where rating = 1 )     rating_2,
                       count(1) filter ( where rating = 1.5 )     rating_3,
                       count(1) filter ( where rating = 2 )     rating_4,
                       count(1) filter ( where rating = 2.5 )     rating_5,
                       count(1) filter ( where rating = 3 )     rating_6,
                       count(1) filter ( where rating = 3.5 )     rating_7,
                       count(1) filter ( where rating = 4 )     rating_8,
                       count(1) filter ( where rating = 4.5 )     rating_9,
                       count(1) filter ( where rating = 5 )     rating_10
                from check_ins
                where created_by = p_uid);
end ;
$function$
;


