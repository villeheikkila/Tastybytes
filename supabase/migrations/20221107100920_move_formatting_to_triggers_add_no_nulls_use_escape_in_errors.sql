drop trigger if exists "stamp_created_by" on "public"."subcategories";

alter table "public"."check_in_comments" alter column "created_by" set not null;

alter table "public"."check_in_reactions" alter column "check_in_id" set not null;

alter table "public"."check_in_reactions" alter column "created_at" set not null;

alter table "public"."check_in_tagged_profiles" alter column "created_at" set not null;

alter table "public"."notifications" alter column "created_at" set not null;

alter table "public"."notifications" alter column "profile_id" set not null;

alter table "public"."product_variants" alter column "is_verified" set not null;

alter table "public"."product_variants" alter column "product_id" set not null;

alter table "public"."products" alter column "is_verified" set not null;

alter table "public"."products_subcategories" alter column "is_verified" set not null;

alter table "public"."sub_brands" alter column "is_verified" set not null;

alter table "public"."subcategories" alter column "is_verified" set not null;

alter table "public"."subcategories" alter column "name" set not null;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__clean_up_check_in()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  -- minimum rating is 0.25, 0 is used to mark the check-in not having a rating
  if new.rating < 0.25 then
    new.rating = null;
  end if;

  if new.review is not null and length(trim(new.review)) = 0 then
    new.review = null;
  else
    new.review = trim(new.review);
  end if;

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__trim_description_empty_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_trimmed_description text;
begin
  select trim(new.description) into v_trimmed_description;

  if v_trimmed_description = '' then
    new.description = null;
  else
    new.description = v_trimmed_description;
  end if;

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__trim_name_empty_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_trimmed_name text;
begin
  select trim(new.name) into v_trimmed_name;

  if v_trimmed_name = '' then
    new.name = null;
  else
    new.name = v_trimmed_name;
  end if;

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__create_check_in(p_product_id bigint, p_rating numeric DEFAULT NULL::integer, p_review text DEFAULT NULL::text, p_manufacturer_id bigint DEFAULT NULL::bigint, p_serving_style_id bigint DEFAULT NULL::bigint, p_friend_ids uuid[] DEFAULT NULL::uuid[], p_flavor_ids bigint[] DEFAULT NULL::bigint[])
 RETURNS SETOF check_ins
 LANGUAGE plpgsql
AS $function$
declare
  v_check_in_id        bigint;
  v_product_variant_id bigint;
begin
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
end
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__create_product(p_name text, p_description text, p_category_id bigint, p_sub_category_ids bigint[], p_brand_id bigint, p_sub_brand_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF products
 LANGUAGE plpgsql
AS $function$
declare
  v_product_id   bigint;
  v_sub_brand_id bigint;
begin
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

  return query (select *
                from products
                where id = v_product_id);
end
$function$
;

CREATE OR REPLACE FUNCTION public.tg__check_friend_status_transition()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if old.blocked_by is not null and old.blocked_by != auth.uid() then
    raise exception E'blocked user can\'t update the friend relation' using errcode = 'blocked';
  end if;
  
  if new.status = 'blocked' then
    new.blocked_by = auth.uid();
  elseif
    new.status = 'accepted' then
    if new.user_id_1 != auth.uid() then
      new.accepted_at = now();
      new.blocked_by = null;
    else
      raise exception E'sender of the friend request can\'t accept the friend request';
    end if;
  elseif old.status in ('accepted', 'blocked') and
         new.status = 'pending' then
    raise exception 'friend status cannot be changed back to pending';
  end if;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__check_subcategory_constraint()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    is_allowed boolean := false;
begin
    select (select category_id from subcategories sc where sc.id = new.subcategory_id)
               = (select category_id from products p where p.id = new.product_id)
    into is_allowed;

    if is_allowed = false
    then
        raise exception 'subcategories must be from the same category as the product';
    end if;
    return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__stamp_created_by()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.created_by = (case when TG_OP = 'INSERT' then auth.uid() else old.created_by end);
  new.created_at = (case when TG_OP = 'INSERT' then now() else old.created_at end);
  return new;
end;
$function$
;

CREATE TRIGGER trim_name_empty_check BEFORE INSERT OR UPDATE ON public.brands FOR EACH ROW EXECUTE FUNCTION tg__trim_name_empty_check();

CREATE TRIGGER clean_up BEFORE INSERT OR UPDATE ON public.check_ins FOR EACH ROW EXECUTE FUNCTION tg__clean_up_check_in();

CREATE TRIGGER trim_name_empty_check BEFORE INSERT OR UPDATE ON public.companies FOR EACH ROW EXECUTE FUNCTION tg__trim_name_empty_check();

CREATE TRIGGER trim_description_empty_check BEFORE INSERT OR UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION tg__trim_description_empty_check();

CREATE TRIGGER trim_name_empty_check BEFORE INSERT OR UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION tg__trim_name_empty_check();

CREATE TRIGGER make_id_immutable BEFORE UPDATE ON public.sub_brands FOR EACH ROW EXECUTE FUNCTION tg__make_id_immutable();

CREATE TRIGGER trim_name_empty_check BEFORE INSERT OR UPDATE ON public.sub_brands FOR EACH ROW EXECUTE FUNCTION tg__trim_name_empty_check();

CREATE TRIGGER check_verification BEFORE INSERT OR UPDATE ON public.subcategories FOR EACH ROW EXECUTE FUNCTION tg__is_verified_check();

CREATE TRIGGER make_id_immutable BEFORE UPDATE ON public.subcategories FOR EACH ROW EXECUTE FUNCTION tg__make_id_immutable();

CREATE TRIGGER trim_name_empty_check BEFORE INSERT OR UPDATE ON public.subcategories FOR EACH ROW EXECUTE FUNCTION tg__trim_name_empty_check();

CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.subcategories FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();


