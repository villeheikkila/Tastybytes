
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

ALTER SCHEMA "public" OWNER TO "postgres";

CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "public";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "public";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE DOMAIN "public"."domain__long_text" AS "text"
	CONSTRAINT "long_text_check" CHECK ((("char_length"(VALUE) >= 1) AND ("char_length"(VALUE) <= 1024)));

ALTER DOMAIN "public"."domain__long_text" OWNER TO "postgres";

CREATE DOMAIN "public"."domain__name" AS "text"
	CONSTRAINT "name_check" CHECK ((("char_length"(VALUE) >= 2) AND ("char_length"(VALUE) <= 16)));

ALTER DOMAIN "public"."domain__name" OWNER TO "postgres";

CREATE DOMAIN "public"."domain__rating" AS numeric
	CONSTRAINT "rating_value_check" CHECK (((VALUE >= (0)::numeric) AND (VALUE <= (5)::numeric)));

ALTER DOMAIN "public"."domain__rating" OWNER TO "postgres";

CREATE DOMAIN "public"."domain__short_text" AS "text"
	CONSTRAINT "short_text_check" CHECK ((("char_length"(VALUE) >= 1) AND ("char_length"(VALUE) <= 100)));

ALTER DOMAIN "public"."domain__short_text" OWNER TO "postgres";

CREATE TYPE "public"."enum__color_scheme" AS ENUM (
    'light',
    'dark',
    'system'
);

ALTER TYPE "public"."enum__color_scheme" OWNER TO "postgres";

CREATE TYPE "public"."enum__friend_status" AS ENUM (
    'accepted',
    'pending',
    'blocked'
);

ALTER TYPE "public"."enum__friend_status" OWNER TO "postgres";

CREATE TYPE "public"."enum__name_display" AS ENUM (
    'full_name',
    'username'
);

ALTER TYPE "public"."enum__name_display" OWNER TO "postgres";

CREATE DOMAIN "public"."rating" AS smallint
	CONSTRAINT "rating_check" CHECK (((VALUE >= 0) AND (VALUE <= 10)));

ALTER DOMAIN "public"."rating" OWNER TO "postgres";

CREATE FUNCTION "public"."delete_notification_on_reaction_delete"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if old.deleted_at is null and new.deleted_at is not null then
    delete from notifications where check_in_reaction_id = old.id;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."delete_notification_on_reaction_delete"() OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__accept_friend_request"("user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
begin
    update friends
    set status = 'accepted'
    where user_id_1 = user_id
      and user_id_2 = auth.uid();
end;
$$;

ALTER FUNCTION "public"."fnc__accept_friend_request"("user_id" "uuid") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__check_if_username_is_available"("p_username" "text") RETURNS boolean
    LANGUAGE "sql"
    AS $$
select exists(select 1 from profiles where lower(username) = lower(p_username));
$$;

ALTER FUNCTION "public"."fnc__check_if_username_is_available"("p_username" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE "public"."check_ins" (
    "id" bigint NOT NULL,
    "rating" "public"."domain__rating",
    "review" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "product_id" bigint NOT NULL,
    "image_file" "text",
    "serving_style_id" bigint,
    "product_variant_id" bigint,
    "location_id" "uuid",
    "blur_hash" "text",
    "check_in_at" timestamp with time zone DEFAULT "now"(),
    "purchase_location_id" "uuid"
);

ALTER TABLE "public"."check_ins" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric DEFAULT NULL::integer, "p_review" "text" DEFAULT NULL::"text", "p_manufacturer_id" bigint DEFAULT NULL::bigint, "p_serving_style_id" bigint DEFAULT NULL::bigint, "p_friend_ids" "uuid"[] DEFAULT NULL::"uuid"[], "p_flavor_ids" bigint[] DEFAULT NULL::bigint[], "p_location_id" "uuid" DEFAULT NULL::"uuid", "p_blur_hash" "text" DEFAULT NULL::"text", "p_check_in_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_purchase_location_id" "uuid" DEFAULT NULL::"uuid") RETURNS SETOF "public"."check_ins"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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

  insert into check_ins (rating, review, product_id, serving_style_id, product_variant_id, location_id, blur_hash,
                         created_by, check_in_at, purchase_location_id)
  values (p_rating, p_review, p_product_id, p_serving_style_id, v_product_variant_id, p_location_id, p_blur_hash,
          auth.uid(), p_check_in_at, p_purchase_location_id)
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
$$;

ALTER FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") OWNER TO "postgres";

CREATE TABLE "public"."check_in_reactions" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "check_in_id" bigint NOT NULL,
    "deleted_at" timestamp with time zone
);

ALTER TABLE "public"."check_in_reactions" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__create_check_in_reaction"("p_check_in_id" bigint) RETURNS SETOF "public"."check_in_reactions"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
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
$$;

ALTER FUNCTION "public"."fnc__create_check_in_reaction"("p_check_in_id" bigint) OWNER TO "postgres";

CREATE TABLE "public"."company_edit_suggestions" (
    "id" bigint NOT NULL,
    "company_id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "logo_url" "text",
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."company_edit_suggestions" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__create_company_edit_suggestion"("p_company_id" bigint, "p_name" "text", "p_logo_url" "text") RETURNS SETOF "public"."company_edit_suggestions"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_company_edit_suggestion_id bigint;
  v_changed_name               text;
  v_changed_logo_url           text;
  v_current_company            companies%ROWTYPE;
BEGIN
  select * from companies where id = p_company_id into v_current_company;

  if v_current_company.name != p_name then
    v_changed_name = p_name;
  end if;

  if v_current_company.name != p_logo_url then
    v_changed_logo_url = p_logo_url;
  end if;

  insert into company_edit_suggestions (company_id, name, logo_url, created_by)
  values (p_company_id, v_changed_name, v_changed_logo_url, auth.uid())
  returning id into v_company_edit_suggestion_id;

  return query (select *
                from company_edit_suggestions
                where id = v_company_edit_suggestion_id);
END

$$;

ALTER FUNCTION "public"."fnc__create_company_edit_suggestion"("p_company_id" bigint, "p_name" "text", "p_logo_url" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__create_deeplink"("p_type" "text", "p_id" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
begin
  return 'tastybytes://deeplink/' || p_type || '/' || p_id;
end;
$$;

ALTER FUNCTION "public"."fnc__create_deeplink"("p_type" "text", "p_id" "text") OWNER TO "postgres";

CREATE TABLE "public"."products" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "category_id" bigint NOT NULL,
    "sub_brand_id" bigint NOT NULL,
    "is_verified" boolean DEFAULT false NOT NULL,
    "logo_file" "text"
);

ALTER TABLE "public"."products" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint DEFAULT NULL::bigint, "p_barcode_type" "text" DEFAULT NULL::"text", "p_barcode_code" "text" DEFAULT NULL::"text") RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_product_id   bigint;
  v_sub_brand_id bigint;
begin
  if fnc__has_permission(auth.uid(), 'can_create_products') is false then
    raise exception 'user has no access to this feature';
  end if;

  if p_sub_brand_id is null then
    select id from sub_brands where name is null and brand_id = p_brand_id limit 1 into v_sub_brand_id;
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
$$;

ALTER FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint, "p_barcode_type" "text", "p_barcode_code" "text") OWNER TO "postgres";

CREATE TABLE "public"."product_edit_suggestions" (
    "id" bigint NOT NULL,
    "product_id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "description" "text",
    "category_id" bigint,
    "sub_brand_id" bigint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid"
);

ALTER TABLE "public"."product_edit_suggestions" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint DEFAULT NULL::bigint) RETURNS SETOF "public"."product_edit_suggestions"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_product_edit_suggestion_id bigint;
  v_changed_name               text;
  v_changed_description        text;
  v_changed_category_id        bigint;
  v_changed_sub_brand_id       bigint;
  v_current_product            products%ROWTYPE;
begin
  select * from products where id = p_product_id into v_current_product;

  if v_current_product.name != p_name then
    v_changed_name = p_name;
  end if;

  if v_current_product.name != p_description then
    v_changed_description = p_description;
  end if;

  if v_current_product.description != p_description then
    v_changed_description = p_description;
  end if;

  if v_current_product.category_id != p_category_id then
    v_changed_category_id = p_category_id;
  end if;

  if v_current_product.sub_brand_id != p_sub_brand_id then
    v_changed_sub_brand_id = p_sub_brand_id;
  end if;

  insert into product_edit_suggestions (product_id, name, description, category_id, sub_brand_id, created_by)
  values (p_product_id, v_changed_name, v_changed_description, v_changed_category_id, v_changed_sub_brand_id,
          auth.uid())
  returning id into v_product_edit_suggestion_id;

  with subcategories_for_product as (select v_product_edit_suggestion_id product_edit_suggestion_id,
                                            unnest(p_sub_category_ids)   subcategory_id),
       current_subcategories as (select subcategory_id from products_subcategories where product_id = p_product_id),
       delete_subcategories as (select o.subcategory_id
                                from current_subcategories o
                                       left join subcategories_for_product n on n.subcategory_id = o.subcategory_id
                                where n is null),
       add_subcategories as (select n.subcategory_id
                             from subcategories_for_product n
                                    left join current_subcategories o on o.subcategory_id is null
                             where o.subcategory_id is null),
       combined as (select subcategory_id, true delete
                    from delete_subcategories
                    union all
                    select subcategory_id, false
                    from add_subcategories)
  insert
  into product_edit_suggestion_subcategories (product_edit_suggestion_id, subcategory_id, delete)
  select v_product_edit_suggestion_id product_edit_suggestion_id, subcategory_id, delete
  from combined;

  return query (select *
                from product_edit_suggestions
                where id = v_product_edit_suggestion_id);
end
$$;

ALTER FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
begin
  if fnc__has_permission(auth.uid(), p_permission_name) is false then
    raise exception 'user has no access to this feature';
  end if;
  return true;
end ;
$$;

ALTER FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__delete_check_in_as_moderator"("p_check_in_id" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__current_user_has_permission('can_delete_check_ins_as_moderator') then
    if (select fnc__is_protected(created_by) from check_ins where id = p_check_in_id) is true then
      raise exception E'check ins can''t be removed from protected users';
    end if;
    delete from check_ins where id = p_check_in_id;
  end if;
end;
$$;

ALTER FUNCTION "public"."fnc__delete_check_in_as_moderator"("p_check_in_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__delete_check_in_comment_as_moderator"("p_check_in_comment_id" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__current_user_has_permission('can_delete_comments') then
    delete from check_in_comments where id = p_check_in_comment_id;
  end if;
end;
$$;

ALTER FUNCTION "public"."fnc__delete_check_in_comment_as_moderator"("p_check_in_comment_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__delete_current_user"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
delete from auth.users where id = auth.uid();
$$;

ALTER FUNCTION "public"."fnc__delete_current_user"() OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__edit_product"("p_product_id" bigint, "p_name" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint DEFAULT NULL::bigint, "p_description" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__has_permission(auth.uid(), 'can_edit_products') is false then
    raise exception 'user has no access to this feature';
  end if;

  delete
  from products_subcategories ps
  where ps.product_id = p_product_id;

  update products
  set name         = p_name,
      description  = p_description,
      category_id  = p_category_id,
      sub_brand_id = p_sub_brand_id
  where id = p_product_id;

  with subcategories_for_product as (select p_product_id               product_id,
                                            unnest(p_sub_category_ids) subcategory_id)
  insert
  into products_subcategories (product_id, subcategory_id)
  select product_id, subcategory_id
  from subcategories_for_product
  on conflict do nothing;
end
$$;

ALTER FUNCTION "public"."fnc__edit_product"("p_product_id" bigint, "p_name" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint, "p_description" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__export_data"() RETURNS TABLE("category" "text", "subcategory" "text", "manufacturer" "text", "brand_owner" "text", "brand" "text", "sub_brand" "text", "name" "text", "reviews" "text", "ratings" "text", "username" "text")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN query (WITH agg_products AS (SELECT cat.name                                         AS category,
                                             string_agg(sc.name, ', '::text ORDER BY sc.name) AS subcategory,
                                             bo.name                                          AS brand_owner,
                                             b.name                                           AS brand,
                                             s.name                                           AS sub_brand,
                                             p.name,
                                             p.id
                                      FROM ((((((products p
                                        LEFT JOIN sub_brands s ON ((p.sub_brand_id = s.id)))
                                        LEFT JOIN brands b ON ((s.brand_id = b.id)))
                                        LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
                                        LEFT JOIN categories cat ON ((p.category_id = cat.id)))
                                        LEFT JOIN products_subcategories ps ON ((ps.product_id = p.id)))
                                        LEFT JOIN subcategories sc ON ((ps.subcategory_id = sc.id)))
                                      GROUP BY cat.name,
                                               bo.name,
                                               b.name,
                                               p.name,
                                               s.name,
                                               p.description,
                                               p.id)
                SELECT ap.category::text,
                       ap.subcategory::text,
                       m.name::text                           AS manufacturer,
                       ap.brand_owner::text,
                       ap.brand::text,
                       ap.sub_brand::text,
                       ap.name::text,
                       string_agg(c.review, ', '::text) AS reviews,
                       string_agg(c.rating::text,
                                  ', '::text)           AS ratings,
                       pr.username::text
                FROM ((((check_ins c
                  LEFT JOIN agg_products ap ON ((ap.id = c.product_id)))
                  LEFT JOIN product_variants pv ON ((pv.id = c.product_variant_id)))
                  LEFT JOIN companies m ON ((pv.manufacturer_id = m.id)))
                  LEFT JOIN profiles pr ON ((c.created_by = pr.id)))
                WHERE c.created_by = auth.uid()
                GROUP BY pr.id,
                         pr.username,
                         ap.category,
                         ap.subcategory,
                         m.name,
                         ap.brand_owner,
                         ap.brand,
                         ap.sub_brand,
                         ap.name,
                         ap.id);
END;
$$;

ALTER FUNCTION "public"."fnc__export_data"() OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_activity_feed"("p_created_after" "date" DEFAULT NULL::"date") RETURNS SETOF "public"."check_ins"
    LANGUAGE "plpgsql"
    AS $$
begin
  return query (with friend_ids as (select case
                                             when user_id_1 != auth.uid()
                                               then user_id_1
                                             else user_id_2 end friend_id
                                    from friends
                                    where status = 'accepted'
                                      and (user_id_1 = auth.uid()
                                       or user_id_2 = auth.uid()))
                select c.*
                from check_ins c
                where (p_created_after is null or c.created_at > p_created_after)
                  and (created_by = auth.uid()
                  or created_by in (select friend_id from friend_ids)))
    order by created_at desc;
end;
$$;

ALTER FUNCTION "public"."fnc__get_activity_feed"("p_created_after" "date") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_category_stats"("p_user_id" "uuid") RETURNS TABLE("id" bigint, "name" "text", "icon" "text", "count" integer)
    LANGUAGE "sql"
    AS $$
with unique_products as (select distinct ci.product_id, p.category_id
                         from check_ins ci
                                left join products p on ci.product_id = p.id
                         where ci.created_by = p_user_id
                         group by ci.product_id, p.category_id),
     stats as (select c.id, c.name, c.icon, count(up.product_id)
               from categories c
                      left join unique_products up on up.category_id = c.id
               group by c.id, c.name)
select *
from stats
where count > 0
order by count desc;
$$;

ALTER FUNCTION "public"."fnc__get_category_stats"("p_user_id" "uuid") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_title       text;
  v_body        text;
  v_check_in_id int;
  v_profile_id  uuid;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' reacted to your check-in of ', b.name, case
                                                                             when sb.name is not null
                                                                               then
                                                                               concat(' ', sb.name, ' ')
                                                                             else
                                                                               ' '
    end, pr.name, ' from ', bo.name)
  from check_in_reactions cir
         left join check_ins c on cir.check_in_id = c.id
         left join profiles p on p.id = cir.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where cir.id = p_check_in_reaction_id
  into v_body;

  select c.id, c.created_by
  from check_in_reactions cir
         left join check_ins c on cir.check_in_id = c.id
  where cir.id = p_check_in_reaction_id
  into v_check_in_id, v_profile_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('checkins', v_check_in_id::text)));
end;
$$;

ALTER FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_title       text;
  v_body        text;
  v_check_in_id int;
  v_profile_id  uuid;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' tagged you in a check-in of ', b.name, case
                                                                             when sb.name is not null
                                                                               then
                                                                               concat(' ', sb.name, ' ')
                                                                             else
                                                                               ' '
    end, pr.name, ' from ', bo.name)
  from check_in_tagged_profiles ctp
         left join check_ins c on ctp.check_in_id = c.id
         left join profiles p on p.id = c.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where ctp.id = p_check_in_tag
  into v_body;

  select c.id, c.created_by
  from check_in_tagged_profiles ctp
         left join check_ins c on ctp.check_in_id = c.id
  into v_check_in_id, v_profile_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('checkins', v_check_in_id::text)));
end;
$$;

ALTER FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_comment_notification"("p_check_in_comment_id" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_title       text;
  v_body        text;
  v_check_in_id int;
  v_profile_id  uuid;
begin
  select '' into v_title;
  select concat(p2.preferred_name, ' commented on your check-in of ', b.name, case
                                                                             when sb.name is not null
                                                                               then
                                                                               concat(' ', sb.name, ' ')
                                                                             else
                                                                               ' '
    end, pr.name, ' from ', bo.name)
  from check_in_comments cic
         left join profiles p2 on cic.created_by = p2.id
         left join check_ins c on cic.check_in_id = c.id
         left join profiles p on p.id = c.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where cic.id = p_check_in_comment_id
  into v_body;

  select c.id, c.created_by
  from check_in_tagged_profiles ctp
         left join check_ins c on ctp.check_in_id = c.id
  into v_check_in_id, v_profile_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('checkins', v_check_in_id::text)));
end;
$$;

ALTER FUNCTION "public"."fnc__get_comment_notification"("p_check_in_comment_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) RETURNS TABLE("total_check_ins" bigint, "average_rating" numeric, "friends_check_ins" bigint, "friends_average_rating" numeric, "current_user_check_ins" bigint, "current_user_average_rating" numeric)
    LANGUAGE "plpgsql"
    AS $$
declare
  v_friend_ids uuid[] = (select array_agg(case when f.user_id_1 = auth.uid() then f.user_id_2 else f.user_id_1 end)
                         from friends f
                         where f.user_id_1 = auth.uid()
                            or f.user_id_2 = auth.uid());
begin
  return query (select count(ci.id)                                                         total_check_ins,
                       round(avg(ci.rating), 2)                                             average_rating,
                       count(ci.id) filter ( where ci.created_by = ANY (v_friend_ids) )     friends_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = ANY (v_friend_ids) ),
                             2)                                                             friends_average_rating,
                       count(ci.id) filter ( where ci.created_by = auth.uid() )             current_user_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = auth.uid() ), 2) current_user_average_rating
                from companies c
                       left join brands b on c.id = b.brand_owner_id
                       left join sub_brands sb on b.id = sb.brand_id
                       left join products p on sb.id = p.sub_brand_id
                       left join check_ins ci on p.id = ci.product_id
                where c.id = p_company_id);
end;
$$;

ALTER FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_contributions_by_user"("p_uid" "uuid") RETURNS TABLE("products" integer, "companies" integer, "brands" integer, "sub_brands" integer, "barcodes" integer)
    LANGUAGE "sql"
    AS $$
with c as (select count(id) created_companies
           from companies
           where created_by = p_uid
             and is_verified = true),
     b as (select count(id) created_brands from brands where created_by = p_uid and is_verified = true),
     s as (select count(id) created_sub_brands
           from sub_brands
           where created_by = p_uid
             and is_verified = true and sub_brands.name is not null),
     p as (select count(id) created_products from products where created_by = p_uid and is_verified = true),
     bc as (select count(id) created_barcodes
            from product_barcodes
            where created_by = p_uid)
select sum(p.created_products)   products,
       sum(c.created_companies)  companies,
       sum(b.created_brands)     brands,
       sum(s.created_sub_brands) sub_brands,
       sum(bc.created_barcodes)  barcodes
from c
       cross join b
       cross join p
       cross join s
       cross join bc;
$$;

ALTER FUNCTION "public"."fnc__get_contributions_by_user"("p_uid" "uuid") OWNER TO "postgres";

CREATE TABLE "public"."profiles" (
    "id" "uuid" NOT NULL,
    "first_name" "text",
    "last_name" "text",
    "username" "public"."domain__name" NOT NULL,
    "avatar_file" "text",
    "name_display" "public"."enum__name_display" DEFAULT 'username'::"public"."enum__name_display",
    "search" "text" GENERATED ALWAYS AS (((("username")::"text" || COALESCE("first_name", ''::"text")) || COALESCE("last_name", ''::"text"))) STORED,
    "preferred_name" "text" GENERATED ALWAYS AS (
CASE
    WHEN (("name_display" = 'full_name'::"public"."enum__name_display") AND ("first_name" IS NOT NULL) AND ("last_name" IS NOT NULL)) THEN (("first_name" || ' '::"text") || "last_name")
    ELSE ("username")::"text"
END) STORED,
    "is_private" boolean DEFAULT false NOT NULL,
    "is_onboarded" boolean DEFAULT false NOT NULL,
    "joined_at" "date" DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."profiles" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_current_profile"() RETURNS SETOF "public"."profiles"
    LANGUAGE "sql"
    AS $$
select *
from profiles
where id = auth.uid()
limit 1;
$$;

ALTER FUNCTION "public"."fnc__get_current_profile"() OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_edge_function_authorization_header"() RETURNS "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
select concat('{ "Authorization": "Bearer ', supabase_anon_key, '" }')::jsonb from secrets limit 1;
$$;

ALTER FUNCTION "public"."fnc__get_edge_function_authorization_header"() OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") RETURNS "text"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
select concat('https://', project_id, '.functions.supabase.co', '/', p_function_name) from secrets limit 1;
$$;

ALTER FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_title       text;
  v_body        text;
  v_profile_id  uuid;
  v_receiver_id uuid;
begin
  select '' into v_title;
  select p.preferred_name || ' sent you a friend request!'
  from friends f
         left join profiles p on p.id = f.user_id_1
  where f.id = p_friend_id
  into v_body;

  select user_id_1, user_id_2
  from friends f
  where f.id = p_friend_id
  into v_profile_id, v_receiver_id;

  return jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object('alert',
                                                                                                             jsonb_build_object('title', v_title, 'body', v_body)
    ))), 'data', jsonb_build_object('link', fnc__create_deeplink('profiles', v_profile_id::text)));
end;
$$;

ALTER FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) OWNER TO "postgres";

CREATE TABLE "public"."locations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "country_code" character(2) NOT NULL,
    "name" "text" NOT NULL,
    "title" "text",
    "longitude" numeric,
    "latitude" numeric,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."locations" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_location_insert_if_not_exist"("p_name" "text", "p_title" "text", "p_latitude" numeric, "p_longitude" numeric, "p_country_code" "text") RETURNS SETOF "public"."locations"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_location locations;
begin
  select *
  from locations
  where name = p_name
    and latitude = p_latitude
    and longitude = p_longitude
    and p_country_code = country_code
  limit 1
  into v_location;

  if v_location is null then
    insert into locations (name, title, latitude, longitude, country_code, created_by)
    values (p_name, p_title, p_latitude, p_longitude, p_country_code::char(2), auth.uid())
    returning *
      into v_location;
  end if;

  return query (select * from locations l where l.id = v_location.id);
end;
$$;

ALTER FUNCTION "public"."fnc__get_location_insert_if_not_exist"("p_name" "text", "p_title" "text", "p_latitude" numeric, "p_longitude" numeric, "p_country_code" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_location_suggestions"("p_longitude" double precision, "p_latitude" double precision) RETURNS SETOF "public"."locations"
    LANGUAGE "sql"
    AS $$
SELECT *
FROM locations
ORDER BY ST_Distance(ST_SetSRID(ST_MakePoint(longitude, latitude), 4326),
                     ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326))
$$;

ALTER FUNCTION "public"."fnc__get_location_suggestions"("p_longitude" double precision, "p_latitude" double precision) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_location_summary"("p_location_id" "uuid") RETURNS TABLE("total_check_ins" bigint, "average_rating" numeric, "friends_check_ins" bigint, "friends_average_rating" numeric, "current_user_check_ins" bigint, "current_user_average_rating" numeric)
    LANGUAGE "plpgsql"
    AS $$
declare
  v_friend_ids uuid[] = (select array_agg(case when f.user_id_1 = auth.uid() then f.user_id_2 else f.user_id_1 end)
                         from friends f
                         where f.user_id_1 = auth.uid()
                            or f.user_id_2 = auth.uid());
begin
  return query (select count(ci.id)                                                         total_check_ins,
                       round(avg(ci.rating), 2)                                             average_rating,
                       count(ci.id) filter ( where ci.created_by = ANY (v_friend_ids) )     friends_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = ANY (v_friend_ids) ),
                             2)                                                             friends_average_rating,
                       count(ci.id) filter ( where ci.created_by = auth.uid() )             current_user_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = auth.uid() ), 2) current_user_average_rating
                from locations l
                       left join check_ins ci on l.id = location_id
                where l.id = p_location_id);
end;
$$;

ALTER FUNCTION "public"."fnc__get_location_summary"("p_location_id" "uuid") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) RETURNS TABLE("total_check_ins" bigint, "average_rating" numeric, "friends_check_ins" bigint, "friends_average_rating" numeric, "current_user_check_ins" bigint, "current_user_average_rating" numeric)
    LANGUAGE "plpgsql"
    AS $$
declare
  v_friend_ids uuid[] = (select array_agg(case when f.user_id_1 = auth.uid() then f.user_id_2 else f.user_id_1 end)
                         from friends f
                         where f.user_id_1 = auth.uid()
                            or f.user_id_2 = auth.uid());
begin
  return query (select count(ci.id)                                                         total_check_ins,
                       round(avg(ci.rating), 2)                                             average_rating,
                       count(ci.id) filter ( where ci.created_by = ANY (v_friend_ids) )     friends_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = ANY (v_friend_ids) ),
                             2)                                                             friends_average_rating,
                       count(ci.id) filter ( where ci.created_by = auth.uid() )             current_user_check_ins,
                       round(avg(ci.rating) filter ( where ci.created_by = auth.uid() ), 2) current_user_average_rating
                from products p
                       left join check_ins ci on p.id = ci.product_id
                where p.id = p_product_id);
end ;
$$;

ALTER FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_profile_summary"("p_uid" "uuid") RETURNS TABLE("total_check_ins" bigint, "unique_check_ins" bigint, "average_rating" numeric, "unrated" bigint, "rating_1" bigint, "rating_2" bigint, "rating_3" bigint, "rating_4" bigint, "rating_5" bigint, "rating_6" bigint, "rating_7" bigint, "rating_8" bigint, "rating_9" bigint, "rating_10" bigint)
    LANGUAGE "plpgsql"
    AS $$
begin
  return query (select count(1)                                               total_check_ins,
                       count(distinct product_id)                             unique_check_ins,
                       round(avg(rating), 2)                                  average_rating,
                       count(1) filter ( where rating is null )               unrated,
                       count(1) filter ( where rating <= 0.5 )                rating_1,
                       count(1) filter ( where rating > 0.5 and rating <= 1 ) rating_2,
                       count(1) filter ( where rating > 1 and rating <= 1.5 ) rating_3,
                       count(1) filter ( where rating > 1.5 and rating <= 2 ) rating_4,
                       count(1) filter ( where rating > 2 and rating <= 2.5 ) rating_5,
                       count(1) filter ( where rating > 2.5 and rating <= 3 ) rating_6,
                       count(1) filter ( where rating > 3 and rating <= 3.5 ) rating_7,
                       count(1) filter ( where rating > 3.5 and rating <= 4 ) rating_8,
                       count(1) filter ( where rating > 4 and rating <= 4.5 ) rating_9,
                       count(1) filter ( where rating > 4.5 and rating <= 5 ) rating_10
                from check_ins
                where created_by = p_uid);
end ;
$$;

ALTER FUNCTION "public"."fnc__get_profile_summary"("p_uid" "uuid") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_device_token" "text", "p_notification" "jsonb") RETURNS TABLE("url" "text", "headers" "jsonb", "body" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_url     text;
  v_headers jsonb;
  v_body    jsonb;
begin
  select format('https://fcm.googleapis.com/v1/projects/%s/messages:send', firebase_project_id)
  from secrets into v_url;

  select jsonb_build_object('Content-Type', 'application/json', 'Authorization', 'Bearer ' || firebase_access_token)
  from secrets into v_headers;

  select jsonb_build_object('message',
                            jsonb_build_object('token', p_receiver_device_token) || p_notification)
  into
    v_body;

  return query (select v_url url, v_headers headers, v_body body);
end
$$;

ALTER FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_device_token" "text", "p_notification" "jsonb") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__get_subcategory_stats"("p_user_id" "uuid", "p_category_id" bigint) RETURNS TABLE("id" bigint, "name" "text", "count" integer)
    LANGUAGE "sql"
    AS $$
with unique_products as (select distinct ci.product_id
                         from check_ins ci
                                left join products p on ci.product_id = p.id
                         where ci.created_by = p_user_id and category_id = p_category_id
                         group by ci.product_id),
     stats as (select sc.id, sc.name, count(up.product_id)
               from subcategories sc
                      left join products_subcategories ps on ps.subcategory_id = sc.id
                      left join unique_products up on up.product_id = ps.product_id
               group by sc.id, sc.name)
select *
from stats
where count > 0
order by count desc;
$$;

ALTER FUNCTION "public"."fnc__get_subcategory_stats"("p_user_id" "uuid", "p_category_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__has_permission"("p_uid" "uuid", "p_permission_name" "text") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
select exists(select 1
              from (((permissions p
                left join roles_permissions rp on ((rp.permission_id = p.id)))
                left join roles r on ((rp.role_id = r.id)))
                left join profiles_roles pr on ((r.id = pr.role_id)))
              where ((pr.profile_id = p_uid) and (p.name = p_permission_name)))
$$;

ALTER FUNCTION "public"."fnc__has_permission"("p_uid" "uuid", "p_permission_name" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__is_protected"("p_uid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
select exists(select 1
              from roles r
                     left join profiles_roles pr on r.id = pr.role_id
              where pr.profile_id = p_uid
                and r.name in ('admin', 'moderator'))
$$;

ALTER FUNCTION "public"."fnc__is_protected"("p_uid" "uuid") OWNER TO "postgres";

CREATE TABLE "public"."notifications" (
    "id" bigint NOT NULL,
    "message" "text",
    "profile_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "friend_request_id" bigint,
    "tagged_in_check_in_id" bigint,
    "check_in_reaction_id" bigint,
    "seen_at" timestamp with time zone,
    "check_in_comment_id" bigint
);

ALTER TABLE "public"."notifications" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__mark_all_notification_read"() RETURNS SETOF "public"."notifications"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
update notifications
set seen_at = now()
where profile_id = auth.uid()
  and seen_at is null
returning *;
$$;

ALTER FUNCTION "public"."fnc__mark_all_notification_read"() OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__mark_check_in_notification_as_read"("p_check_in_id" bigint) RETURNS SETOF "public"."notifications"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
update notifications
set seen_at = now()
where profile_id = auth.uid()
  and (check_in_reaction_id in (select id from check_in_reactions where check_in_id = p_check_in_id) or
       tagged_in_check_in_id in (select id from check_in_tagged_profiles where check_in_id = p_check_in_id))
returning *;
$$;

ALTER FUNCTION "public"."fnc__mark_check_in_notification_as_read"("p_check_in_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__mark_friend_request_notification_as_read"() RETURNS SETOF "public"."notifications"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
update notifications
set seen_at = now()
where friend_request_id is not null
  and profile_id = auth.uid()
returning *;
$$;

ALTER FUNCTION "public"."fnc__mark_friend_request_notification_as_read"() OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__mark_notification_as_read"("p_notification_id" bigint) RETURNS SETOF "public"."notifications"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
update notifications
set seen_at = now()
where id = p_notification_id
  and profile_id = auth.uid()
returning *;
$$;

ALTER FUNCTION "public"."fnc__mark_notification_as_read"("p_notification_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__merge_locations"("p_location_id" "uuid", "p_to_location_id" "uuid") RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__current_user_has_permission('can_merge_locations') then
    update check_ins set location_id = p_to_location_id where location_id = p_location_id;
    delete from locations where id = p_location_id;
  end if;
end;
$$;

ALTER FUNCTION "public"."fnc__merge_locations"("p_location_id" "uuid", "p_to_location_id" "uuid") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__current_user_has_permission('can_merge_products') then
    alter table products disable trigger check_verification;
    update product_barcodes set product_id = p_to_product_id where product_id = p_product_id;
    update check_ins set product_id = p_to_product_id where product_id = p_product_id;
    -- some objects are lost, such as edit suggestions
    delete from products where id = p_product_id;
    alter table products
      enable trigger check_verification;
  end if;
end;
$$;

ALTER FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_response_id           bigint;
begin
  select net.http_post(
           url := url,
           headers := headers,
           body := body
           ) request_id
  into v_response_id;

  return v_response_id;
end
$$;

ALTER FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__refresh_firebase_access_token"() RETURNS "void"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_url text;
  v_headers jsonb;
  v_response_id int;
begin
  select fnc__get_edge_function_url('get-fcm-access-token') into v_url;
  select fnc__get_edge_function_authorization_header() into v_headers;
  select net.http_get(v_url, headers := v_headers) into v_response_id;
  end;
$$;

ALTER FUNCTION "public"."fnc__refresh_firebase_access_token"() OWNER TO "postgres";

CREATE VIEW "public"."view__search_product_ratings" AS
SELECT
    NULL::bigint AS "id",
    NULL::"public"."domain__short_text" AS "name",
    NULL::"text" AS "description",
    NULL::timestamp with time zone AS "created_at",
    NULL::"uuid" AS "created_by",
    NULL::bigint AS "category_id",
    NULL::bigint AS "sub_brand_id",
    NULL::"text" AS "logo_file",
    NULL::boolean AS "is_verified",
    NULL::"tsvector" AS "search_value",
    NULL::bigint AS "total_check_ins",
    NULL::numeric AS "average_rating",
    NULL::bigint AS "friends_check_ins",
    NULL::numeric AS "friends_average_rating",
    NULL::bigint AS "current_user_check_ins",
    NULL::numeric AS "current_user_average_rating",
    NULL::bigint AS "check_ins_during_previous_month";

ALTER TABLE "public"."view__search_product_ratings" OWNER TO "postgres";

CREATE MATERIALIZED VIEW "public"."materialized_view__search_product_ratings" AS
 SELECT "view__search_product_ratings"."id",
    "view__search_product_ratings"."name",
    "view__search_product_ratings"."description",
    "view__search_product_ratings"."created_at",
    "view__search_product_ratings"."created_by",
    "view__search_product_ratings"."category_id",
    "view__search_product_ratings"."sub_brand_id",
    "view__search_product_ratings"."logo_file",
    "view__search_product_ratings"."is_verified",
    "view__search_product_ratings"."search_value",
    "view__search_product_ratings"."total_check_ins",
    "view__search_product_ratings"."average_rating",
    "view__search_product_ratings"."friends_check_ins",
    "view__search_product_ratings"."friends_average_rating",
    "view__search_product_ratings"."current_user_check_ins",
    "view__search_product_ratings"."current_user_average_rating",
    "view__search_product_ratings"."check_ins_during_previous_month"
   FROM "public"."view__search_product_ratings"
  WITH NO DATA;

ALTER TABLE "public"."materialized_view__search_product_ratings" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__search_products"("p_search_term" "text", "p_only_non_checked_in" boolean, "p_category_name" "text" DEFAULT NULL::"text", "p_subcategory_id" bigint DEFAULT NULL::bigint) RETURNS SETOF "public"."materialized_view__search_product_ratings"
    LANGUAGE "sql"
    AS $$
select pr.*
from view__search_product_ratings pr
       left join categories cat on pr.category_id = cat.id
       left join products_subcategories psc on psc.product_id = pr.id and psc.subcategory_id = p_subcategory_id
where (p_category_name is null or cat.name = p_category_name)
  and (p_subcategory_id is null or psc.subcategory_id is not null)
  and (p_only_non_checked_in is false or pr.current_user_check_ins = 0)
  and (pr.search_value @@ to_tsquery(replace(p_search_term, ' ', ' & ') || ':*'))
order by ts_rank(search_value, to_tsquery(replace(p_search_term, ' ', ' & ') || ':*')) desc;
$$;

ALTER FUNCTION "public"."fnc__search_products"("p_search_term" "text", "p_only_non_checked_in" boolean, "p_category_name" "text", "p_subcategory_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") RETURNS SETOF "public"."profiles"
    LANGUAGE "sql"
    AS $$
select *
from profiles
WHERE username ilike p_search_term
   or first_name ilike p_search_term
   or last_name ilike p_search_term;
$$;

ALTER FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__soft_delete_check_in_reaction"("p_check_in_reaction_id" bigint) RETURNS SETOF "public"."check_in_reactions"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
update check_in_reactions
set deleted_at = now()
where id = p_check_in_reaction_id
  and created_by = auth.uid()
returning *;
$$;

ALTER FUNCTION "public"."fnc__soft_delete_check_in_reaction"("p_check_in_reaction_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" numeric DEFAULT NULL::numeric, "p_review" "text" DEFAULT NULL::"text", "p_manufacturer_id" bigint DEFAULT NULL::bigint, "p_serving_style_id" bigint DEFAULT NULL::bigint, "p_friend_ids" "uuid"[] DEFAULT NULL::"uuid"[], "p_flavor_ids" bigint[] DEFAULT NULL::bigint[], "p_location_id" "uuid" DEFAULT NULL::"uuid", "p_blur_hash" "text" DEFAULT NULL::"text", "p_check_in_at" timestamp with time zone DEFAULT NULL::timestamp with time zone, "p_purchase_location_id" "uuid" DEFAULT NULL::"uuid") RETURNS SETOF "public"."check_ins"
    LANGUAGE "plpgsql"
    AS $$
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
      location_id        = p_location_id,
      blur_hash          = p_blur_hash,
      check_in_at        = p_check_in_at,
      purchase_location_id = p_purchase_location_id
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
$$;

ALTER FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") OWNER TO "postgres";

CREATE TABLE "public"."profile_push_notifications" (
    "firebase_registration_token" "text" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "send_friend_request_notifications" boolean DEFAULT false NOT NULL,
    "send_reaction_notifications" boolean DEFAULT false NOT NULL,
    "send_tagged_check_in_notifications" boolean DEFAULT false NOT NULL,
    "send_comment_notifications" boolean DEFAULT false
);

ALTER TABLE "public"."profile_push_notifications" OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") RETURNS "public"."profile_push_notifications"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
insert into profile_push_notifications (firebase_registration_token, created_by)
values (p_push_notification_token, auth.uid())
on conflict (firebase_registration_token)
  do update set updated_at = now(), created_by = auth.uid()
returning *;
$$;

ALTER FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__user_can_view_check_in"("p_uid" "uuid", "p_check_in_id" bigint) RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
select exists(select 1
              from check_ins ci
                     left join profiles p on ci.created_by = p.id
              where ci.id = p_check_in_id
                and (p_uid = ci.created_by
                or p.is_private = false
                or fnc__user_is_friends_with(p_uid, ci.created_by)));
$$;

ALTER FUNCTION "public"."fnc__user_can_view_check_in"("p_uid" "uuid", "p_check_in_id" bigint) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__user_is_friends_with"("p_uid" "uuid", "p_friend_uid" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE
    AS $$
select exists(select 1
              from friends
              where status = 'accepted' and (user_id_1 = p_uid and user_id_2 = p_friend_uid)
                 or (user_id_2 = p_uid and user_id_1 = p_friend_uid))
$$;

ALTER FUNCTION "public"."fnc__user_is_friends_with"("p_uid" "uuid", "p_friend_uid" "uuid") OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__verify_brand"("p_brand_id" bigint, "p_is_verified" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table brands
    disable trigger check_verification;

  update brands
  set is_verified = p_is_verified
  where id = p_brand_id;
  
  alter table brands
    enable trigger check_verification;
end
$$;

ALTER FUNCTION "public"."fnc__verify_brand"("p_brand_id" bigint, "p_is_verified" boolean) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__verify_company"("p_company_id" bigint, "p_is_verified" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table companies
    disable trigger check_verification;

  update companies
  set is_verified = p_is_verified
  where id = p_company_id;

  alter table companies
    enable trigger check_verification;
end
$$;

ALTER FUNCTION "public"."fnc__verify_company"("p_company_id" bigint, "p_is_verified" boolean) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__verify_product"("p_product_id" bigint, "p_is_verified" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table products
    disable trigger check_verification;

  update products
  set is_verified = p_is_verified
  where id = p_product_id;

  alter table products
    enable trigger check_verification;
end
$$;

ALTER FUNCTION "public"."fnc__verify_product"("p_product_id" bigint, "p_is_verified" boolean) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__verify_sub_brand"("p_sub_brand_id" bigint, "p_is_verified" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table sub_brands
    disable trigger check_verification;

  update sub_brands
  set is_verified = p_is_verified
  where id = p_sub_brand_id;

  alter table sub_brands
    enable trigger check_verification;
end
$$;

ALTER FUNCTION "public"."fnc__verify_sub_brand"("p_sub_brand_id" bigint, "p_is_verified" boolean) OWNER TO "postgres";

CREATE FUNCTION "public"."fnc__verify_subcategory"("p_subcategory_id" bigint, "p_is_verified" boolean) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    raise exception 'user has no access to this feature';
  end if;

  alter table subcategories
    disable trigger check_verification;

  update subcategories
  set is_verified = p_is_verified
  where id = p_subcategory_id;

  alter table subcategories
    enable trigger check_verification;
end
$$;

ALTER FUNCTION "public"."fnc__verify_subcategory"("p_subcategory_id" bigint, "p_is_verified" boolean) OWNER TO "postgres";

CREATE FUNCTION "public"."tg__add_user_role"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_role_id bigint;
begin
  select id from roles where name = 'user' into v_role_id;

  insert
  into public.profiles_roles (profile_id, role_id)
  values (new.id, v_role_id);
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__add_user_role"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__check_friend_status_transition"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
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
$$;

ALTER FUNCTION "public"."tg__check_friend_status_transition"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__check_subcategory_constraint"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
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
$$;

ALTER FUNCTION "public"."tg__check_subcategory_constraint"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__clean_up_check_in"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
  declare
    v_trimmed_review text;
begin
  -- minimum rating is 0.25, 0 is used to mark the check-in not having a rating
  if new.rating < 0.25 then
    new.rating = null;
  end if;

  select trim(regexp_replace(new.review, E'[\\n\\r\\u2028]+', ' ', 'g' )) into v_trimmed_review;

  if new.review is null or length(v_trimmed_review) = 0 then
    new.review = null;
  else
    new.review = v_trimmed_review;
  end if;

  return new;
end;
$$;

ALTER FUNCTION "public"."tg__clean_up_check_in"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__clean_up_profile_values"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  if coalesce(trim(new.username), '') = '' then
    new.username := null;
  else
    new.username := trim(new.username);
  end if;

  if coalesce(trim(new.first_name), '') = '' then
    new.first_name := null;
  else
    if length(trim(new.first_name)) > 32 then
      raise E'First name is too long, length must be under 32 characters.';
    end if;
    
    new.first_name := trim(new.first_name);
  end if;

  if coalesce(trim(new.last_name), '') = '' then
    new.last_name := null;
  else
    if length(trim(new.first_name)) > 32 then
      raise E'Last name is too long, length must be under 32 characters.';
    end if;

    new.last_name := trim(new.last_name);
  end if;

  return new;
end;
$$;

ALTER FUNCTION "public"."tg__clean_up_profile_values"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__create_default_sub_brand"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  insert into sub_brands (name, brand_id, created_by, is_verified)
  values (null, new.id, auth.uid(), true);
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__create_default_sub_brand"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__create_friend_request"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  new.user_id_1 = auth.uid();
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__create_friend_request"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__create_profile_for_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
    insert
    into public.profiles (id, username)
    values (new.id, new.raw_user_meta_data ->> 'p_username'::text);
    return new;
end;
$$;

ALTER FUNCTION "public"."tg__create_profile_for_new_user"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__create_profile_settings"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
    insert
    into public.profile_settings (id)
    values (new.id);
    return new;
end;
$$;

ALTER FUNCTION "public"."tg__create_profile_settings"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__forbid_changing_check_in_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new.check_in_id = old.check_in_id;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__forbid_changing_check_in_id"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__forbid_send_messages_too_often"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_last_message timestamptz;
begin
  select created_at
  from check_in_comments
  where created_by = auth.uid()
  order by created_at desc
  limit 1
  into v_last_message;

  if v_last_message + interval '10 seconds' > now() then
    raise exception 'user is only allowed to send a comment every 10 seconds' using errcode = 'too_rapid_commenting';
  end if;
  
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__forbid_send_messages_too_often"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__friend_request_check"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_already_exists bool := false;
begin
  select exists(select 1
                from friends f
                where (f.user_id_1 = new.user_id_1 and f.user_id_1 = new.user_id_2)
                   or (f.user_id_1 = new.user_id_2 and f.user_id_1 = new.user_id_1))
  into v_already_exists;
  if v_already_exists then
    raise exception 'users are already friends with each other' using errcode = 'already_friends';
  end if;

  -- make sure that the sender is the current user and that the profiles can't be updated later
  new.user_id_1 = (case when TG_OP = 'INSERT' then auth.uid() else old.user_id_1 end);
  new.user_id_2 = (case when TG_OP = 'INSERT' then new.user_id_2 else old.user_id_2 end);
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__friend_request_check"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__is_verified_check"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    new.is_verified = (case
                         when TG_OP = 'INSERT' then false
                         else old.is_verified end);
  else
    -- Everything created by an user that can verify is created as verified
    new.is_verified = (case
                         when TG_OP = 'INSERT' then true
                         else (case when new.is_verified is null then old.is_verified else new.is_verified end) end);
  end if;

  return new;
end;
$$;

ALTER FUNCTION "public"."tg__is_verified_check"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__make_id_immutable"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new.id := old.id;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__make_id_immutable"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__must_be_friends"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
DECLARE
  v_friend_id bigint;
begin
  select id
  from friends
  where (user_id_1 = auth.uid() and user_id_2 = new.profile_id)
     or (user_id_1 = new.profile_id and user_id_2 = auth.uid())
  into v_friend_id;

  if v_friend_id is null then
    raise exception 'included profile must be a friend' using errcode = 'not_in_friends';
  else
    return new;
  end if;
end;
$$;

ALTER FUNCTION "public"."tg__must_be_friends"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__refresh_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = (case
                      when tg_op = 'update' and old.updated_at >= now() then old.updated_at + interval '1 millisecond'
                      else now() end);
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__refresh_updated_at"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__remove_unused_tokens"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  delete from profile_push_notifications where updated_at < now() - interval '1 years';
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__remove_unused_tokens"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__send_check_in_comment_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_check_in_created_by uuid;
  v_send_notification bool;
begin
    select created_by into v_check_in_created_by from check_ins ci where ci.id = new.check_in_id;
  select send_comment_notifications into v_send_notification from profile_settings where id = v_check_in_created_by;

  if v_send_notification then
      insert into notifications (profile_id, check_in_comment_id) values (v_check_in_created_by, new.id);
  end if;

  return new;
end;
$$;

ALTER FUNCTION "public"."tg__send_check_in_comment_notification"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__send_check_in_reaction_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_profile_id        uuid;
  v_send_notification bool;
begin
  select created_by into v_profile_id from check_ins where id = new.check_in_id;
  select send_reaction_notifications into v_send_notification from profile_settings where id = v_profile_id;

  if v_profile_id != auth.uid() and v_send_notification then
    insert into notifications (profile_id, check_in_reaction_id) values (v_profile_id, new.id);
  end if;
  
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__send_check_in_reaction_notification"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__send_friend_request_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare 
  v_send_notification bool;
begin
  select send_friend_request_notifications into v_send_notification from profile_settings where id = new.user_id_2;

  if v_send_notification then
      insert into notifications (profile_id, friend_request_id) values (new.user_id_2, new.id);
  end if;

  return new;
end;
$$;

ALTER FUNCTION "public"."tg__send_friend_request_notification"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__send_push_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_notification                    jsonb;
  v_push_notification_device_tokens text[];
  v_current_device_token            text;
begin
  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_friend_request_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_reaction_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  elseif new.tagged_in_check_in_id is not null then
    select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_tagged_check_in_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  elseif new.check_in_comment_id is not null then
    select fnc__get_comment_notification(new.check_in_comment_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_comment_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
  end if;

  if array_length(v_push_notification_device_tokens, 1) is null or
     array_length(v_push_notification_device_tokens, 1) = 0 then
    return new;
  else
    foreach v_current_device_token in array v_push_notification_device_tokens
      loop
        perform fnc__post_request(url, headers, body)
        from fnc__get_push_notification_request(v_current_device_token, v_notification);
      end loop;
  end if;

  return new;
end;
$$;

ALTER FUNCTION "public"."tg__send_push_notification"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__send_tagged_in_check_in_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_send_notification bool;
begin
  select send_tagged_check_in_notifications into v_send_notification from profile_settings where id = new.profile_id;
  
  if v_send_notification then
      insert into notifications (profile_id, tagged_in_check_in_id) values (new.profile_id, new.id);
  end if;
  
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__send_tagged_in_check_in_notification"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__set_avatar_on_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  if new.bucket_id = 'avatars' then
    delete from storage.objects where bucket_id = 'avatars' and owner = new.owner;
    with parts as (select string_to_array(new.name, '/') arr),
         formatted_parts as (select array_to_string(arr[2:], '')                              image_url,
                                    substr(array_to_string(arr[2:], ''), 0,
                                           strpos(array_to_string(arr[2:], ''), '.'))::bigint check_in_id
                             from parts)
    update
      public.profiles
    set avatar_file = fp.image_url
    from formatted_parts fp
    where id = new.owner;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__set_avatar_on_upload"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__set_brand_logo_on_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  if new.bucket_id = 'brand-logos' then
    update
      public.brands
    set logo_file = new.name
    where id = split_part(new.name, '_', 1)::bigint;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__set_brand_logo_on_upload"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__set_check_in_image_on_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  if new.bucket_id = 'check-ins' then
    with parts as (select string_to_array(new.name, '/') arr),
         formatted_parts as (select array_to_string(arr[2:], '')                      image_url,
                                    substr(array_to_string(arr[2:], ''), 0,
                                           strpos(array_to_string(arr[2:], ''), '.'))::bigint check_in_id
                             from parts)
    update
      check_ins
    set image_file = fp.image_url
    from formatted_parts fp
    where created_by = new.owner
      and id = fp.check_in_id;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__set_check_in_image_on_upload"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__set_company_logo_on_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  if new.bucket_id = 'logos' then
    update
      public.companies
    set logo_file = new.name
    where id = split_part(new.name, '_', 1)::bigint;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__set_company_logo_on_upload"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__set_product_logo_on_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  if new.bucket_id = 'product-logos' then
    update
      public.products
    set logo_file = new.name
    where id = split_part(new.name, '_', 1)::bigint;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__set_product_logo_on_upload"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__stamp_created_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new.created_at = (case when TG_OP = 'INSERT' then now() else old.created_at end);
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__stamp_created_at"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__stamp_created_by"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new.created_by = (case when TG_OP = 'INSERT' then auth.uid() else old.created_by end);
  new.created_at = (case when TG_OP = 'INSERT' then now() else old.created_at end);
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__stamp_created_by"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__stamp_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at = (case
                      when tg_op = 'update' and old.updated_at >= now() then old.updated_at + interval '1 millisecond'
                      else now() end);
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__stamp_updated_at"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__trim_description_empty_check"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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
$$;

ALTER FUNCTION "public"."tg__trim_description_empty_check"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__trim_name_empty_check"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
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
$$;

ALTER FUNCTION "public"."tg__trim_name_empty_check"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__update_notification_badges"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_device_tokens        text[];
  v_current_device_token text;
  v_number_of_unread     int;
begin
  select array_agg(firebase_registration_token)
  from profile_push_notifications
  where created_by = new.profile_id
  into v_device_tokens;

  select count(1) from notifications where profile_id = new.profile_id and seen_at is null into v_number_of_unread;

  if array_length(v_device_tokens, 1) is null or array_length(v_device_tokens, 1) = 0 then
    return new;
  else
    foreach v_current_device_token in array v_device_tokens
      loop
        perform fnc__post_request(url, headers, body)
        from fnc__get_push_notification_request(v_current_device_token, jsonb_build_object('apns',
                                                                                           json_build_object('payload',
                                                                                                             json_build_object(
                                                                                                               'aps',
                                                                                                               jsonb_build_object(
                                                                                                                 'badge',
                                                                                                                 v_number_of_unread)))));
      end loop;
  end if;
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__update_notification_badges"() OWNER TO "postgres";

CREATE FUNCTION "public"."tg__use_current_user_profile_id_as_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new.id := auth.uid();
  return new;
end;
$$;

ALTER FUNCTION "public"."tg__use_current_user_profile_id_as_id"() OWNER TO "postgres";

CREATE TABLE "public"."brand_edit_suggestions" (
    "id" bigint NOT NULL,
    "brand_id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "brand_owner_id" bigint,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."brand_edit_suggestions" OWNER TO "postgres";

CREATE SEQUENCE "public"."brand_edit_suggestions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."brand_edit_suggestions_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."brand_edit_suggestions_id_seq" OWNED BY "public"."brand_edit_suggestions"."id";

CREATE TABLE "public"."brands" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "brand_owner_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "is_verified" boolean DEFAULT false NOT NULL,
    "logo_file" "text"
);

ALTER TABLE "public"."brands" OWNER TO "postgres";

ALTER TABLE "public"."brands" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."brands_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."categories" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "icon" "text"
);

ALTER TABLE "public"."categories" OWNER TO "postgres";

ALTER TABLE "public"."categories" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."categories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."category_serving_styles" (
    "category_id" bigint NOT NULL,
    "serving_style_id" bigint NOT NULL
);

ALTER TABLE "public"."category_serving_styles" OWNER TO "postgres";

CREATE TABLE "public"."check_in_comments" (
    "id" bigint NOT NULL,
    "content" "public"."domain__long_text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "check_in_id" integer NOT NULL
);

ALTER TABLE "public"."check_in_comments" OWNER TO "postgres";

ALTER TABLE "public"."check_in_comments" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."check_in_comments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."check_in_flavors" (
    "check_in_id" bigint,
    "flavor_id" bigint
);

ALTER TABLE "public"."check_in_flavors" OWNER TO "postgres";

ALTER TABLE "public"."check_in_reactions" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."check_in_reactions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."check_in_tagged_profiles" (
    "check_in_id" bigint NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "id" bigint NOT NULL
);

ALTER TABLE "public"."check_in_tagged_profiles" OWNER TO "postgres";

CREATE SEQUENCE "public"."check_in_tagged_profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."check_in_tagged_profiles_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."check_in_tagged_profiles_id_seq" OWNED BY "public"."check_in_tagged_profiles"."id";

ALTER TABLE "public"."check_ins" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."check_ins_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."companies" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "logo_file" "text",
    "is_verified" boolean DEFAULT false,
    "subsidiary_of" bigint,
    "description" "text"
);

ALTER TABLE "public"."companies" OWNER TO "postgres";

ALTER TABLE "public"."companies" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."companies_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE SEQUENCE "public"."company_edit_suggestions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."company_edit_suggestions_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."company_edit_suggestions_id_seq" OWNED BY "public"."company_edit_suggestions"."id";

CREATE TABLE "public"."countries" (
    "country_code" character(2) NOT NULL,
    "name" "text" NOT NULL,
    "emoji" "text" NOT NULL
);

ALTER TABLE "public"."countries" OWNER TO "postgres";

CREATE TABLE "public"."documents" (
    "page_name" "text" NOT NULL,
    "document" "jsonb"
);

ALTER TABLE "public"."documents" OWNER TO "postgres";

CREATE TABLE "public"."flavors" (
    "id" bigint NOT NULL,
    "name" "text"
);

ALTER TABLE "public"."flavors" OWNER TO "postgres";

ALTER TABLE "public"."flavors" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."flavors_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE "public"."friends" (
    "id" bigint NOT NULL,
    "user_id_1" "uuid" NOT NULL,
    "user_id_2" "uuid" NOT NULL,
    "status" "public"."enum__friend_status" DEFAULT 'pending'::"public"."enum__friend_status" NOT NULL,
    "accepted_at" "date",
    "blocked_by" "uuid",
    "created_at" "date" DEFAULT "now"() NOT NULL,
    CONSTRAINT "friends_check" CHECK (("user_id_1" <> "user_id_2"))
);

ALTER TABLE "public"."friends" OWNER TO "postgres";

ALTER TABLE "public"."friends" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."friends_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE SEQUENCE "public"."notifications_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."notifications_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."notifications_id_seq" OWNED BY "public"."notifications"."id";

CREATE TABLE "public"."permissions" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL
);

ALTER TABLE "public"."permissions" OWNER TO "postgres";

CREATE SEQUENCE "public"."permissions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."permissions_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."permissions_id_seq" OWNED BY "public"."permissions"."id";

CREATE TABLE "public"."product_barcodes" (
    "id" bigint NOT NULL,
    "product_id" bigint NOT NULL,
    "barcode" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "type" "text" NOT NULL
);

ALTER TABLE "public"."product_barcodes" OWNER TO "postgres";

CREATE SEQUENCE "public"."product_barcodes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."product_barcodes_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."product_barcodes_id_seq" OWNED BY "public"."product_barcodes"."id";

CREATE TABLE "public"."product_duplicate_suggestions" (
    "product_id" bigint NOT NULL,
    "duplicate_of_product_id" bigint NOT NULL,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."product_duplicate_suggestions" OWNER TO "postgres";

CREATE TABLE "public"."product_edit_suggestion_subcategories" (
    "id" bigint NOT NULL,
    "product_edit_suggestion_id" bigint NOT NULL,
    "subcategory_id" bigint NOT NULL,
    "delete" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."product_edit_suggestion_subcategories" OWNER TO "postgres";

CREATE SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."product_edit_suggestion_subcategories_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" OWNED BY "public"."product_edit_suggestion_subcategories"."id";

CREATE SEQUENCE "public"."product_edit_suggestions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."product_edit_suggestions_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."product_edit_suggestions_id_seq" OWNED BY "public"."product_edit_suggestions"."id";

CREATE TABLE "public"."product_variants" (
    "id" bigint NOT NULL,
    "product_id" bigint NOT NULL,
    "manufacturer_id" bigint,
    "created_by" "uuid",
    "is_verified" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."product_variants" OWNER TO "postgres";

CREATE SEQUENCE "public"."product_variants_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."product_variants_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."product_variants_id_seq" OWNED BY "public"."product_variants"."id";

ALTER TABLE "public"."products" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."products_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."products_subcategories" (
    "product_id" bigint NOT NULL,
    "subcategory_id" bigint NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_verified" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."products_subcategories" OWNER TO "postgres";

ALTER TABLE "public"."products_subcategories" ALTER COLUMN "product_id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."products_subcategories_product_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."profile_settings" (
    "id" "uuid" NOT NULL,
    "color_scheme" "public"."enum__color_scheme" DEFAULT 'system'::"public"."enum__color_scheme" NOT NULL,
    "send_reaction_notifications" boolean DEFAULT true NOT NULL,
    "send_tagged_check_in_notifications" boolean DEFAULT true NOT NULL,
    "send_friend_request_notifications" boolean DEFAULT true NOT NULL,
    "send_comment_notifications" boolean DEFAULT true
);

ALTER TABLE "public"."profile_settings" OWNER TO "postgres";

CREATE TABLE "public"."profiles_roles" (
    "profile_id" "uuid" NOT NULL,
    "role_id" bigint NOT NULL
);

ALTER TABLE "public"."profiles_roles" OWNER TO "postgres";

CREATE TABLE "public"."reports" (
    "id" bigint NOT NULL,
    "message" "text",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "check_in_id" bigint,
    "product_id" bigint,
    "company_id" bigint,
    "check_in_comment_id" bigint,
    "brand_id" bigint,
    "sub_brand_id" bigint
);

ALTER TABLE "public"."reports" OWNER TO "postgres";

CREATE SEQUENCE "public"."reports_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."reports_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."reports_id_seq" OWNED BY "public"."reports"."id";

CREATE TABLE "public"."roles" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL
);

ALTER TABLE "public"."roles" OWNER TO "postgres";

ALTER TABLE "public"."roles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."roles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE "public"."roles_permissions" (
    "role_id" bigint NOT NULL,
    "permission_id" bigint NOT NULL
);

ALTER TABLE "public"."roles_permissions" OWNER TO "postgres";

CREATE TABLE "public"."secrets" (
    "firebase_access_token" "text",
    "supabase_anon_key" "text" NOT NULL,
    "project_id" "text" NOT NULL,
    "firebase_project_id" "text"
);

ALTER TABLE "public"."secrets" OWNER TO "postgres";

CREATE TABLE "public"."serving_styles" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "logo" "text"
);

ALTER TABLE "public"."serving_styles" OWNER TO "postgres";

ALTER TABLE "public"."serving_styles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."serving_styles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE TABLE "public"."sub_brand_edit_suggestion" (
    "id" bigint NOT NULL,
    "sub_brand_id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "brand_id" bigint,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."sub_brand_edit_suggestion" OWNER TO "postgres";

CREATE SEQUENCE "public"."sub_brand_edit_suggestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE "public"."sub_brand_edit_suggestion_id_seq" OWNER TO "postgres";

ALTER SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" OWNED BY "public"."sub_brand_edit_suggestion"."id";

CREATE TABLE "public"."sub_brands" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "brand_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "is_verified" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."sub_brands" OWNER TO "postgres";

ALTER TABLE "public"."sub_brands" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."sub_brands_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

CREATE TABLE "public"."subcategories" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "category_id" bigint NOT NULL,
    "is_verified" boolean DEFAULT false NOT NULL
);

ALTER TABLE "public"."subcategories" OWNER TO "postgres";

ALTER TABLE "public"."subcategories" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."subcategories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);

CREATE VIEW "public"."view__brand_ratings" AS
SELECT
    NULL::bigint AS "id",
    NULL::"public"."domain__short_text" AS "name",
    NULL::bigint AS "brand_owner_id",
    NULL::timestamp with time zone AS "created_at",
    NULL::"uuid" AS "created_by",
    NULL::boolean AS "is_verified",
    NULL::"text" AS "logo_file",
    NULL::bigint AS "total_check_ins",
    NULL::numeric AS "average_rating",
    NULL::bigint AS "friends_check_ins",
    NULL::numeric AS "friends_average_rating",
    NULL::bigint AS "current_user_check_ins",
    NULL::numeric AS "current_user_average_rating";

ALTER TABLE "public"."view__brand_ratings" OWNER TO "postgres";

CREATE VIEW "public"."view__current_user_friends" AS
 SELECT
        CASE
            WHEN ("friends"."user_id_1" = "auth"."uid"()) THEN "friends"."user_id_2"
            ELSE "friends"."user_id_1"
        END AS "id"
   FROM "public"."friends"
  WHERE ((("friends"."user_id_1" = "auth"."uid"()) OR ("friends"."user_id_2" = "auth"."uid"())) AND ("friends"."status" = 'accepted'::"public"."enum__friend_status"));

ALTER TABLE "public"."view__current_user_friends" OWNER TO "postgres";

CREATE VIEW "public"."view__product_ratings" AS
SELECT
    NULL::bigint AS "id",
    NULL::"public"."domain__short_text" AS "name",
    NULL::"text" AS "description",
    NULL::timestamp with time zone AS "created_at",
    NULL::"uuid" AS "created_by",
    NULL::bigint AS "category_id",
    NULL::bigint AS "sub_brand_id",
    NULL::boolean AS "is_verified",
    NULL::"text" AS "logo_file",
    NULL::bigint AS "total_check_ins",
    NULL::numeric AS "average_rating",
    NULL::bigint AS "friends_check_ins",
    NULL::numeric AS "friends_average_rating",
    NULL::bigint AS "current_user_check_ins",
    NULL::numeric AS "current_user_average_rating",
    NULL::bigint AS "check_ins_during_previous_month";

ALTER TABLE "public"."view__product_ratings" OWNER TO "postgres";

CREATE VIEW "public"."view__profile_product_ratings" AS
SELECT
    NULL::bigint AS "id",
    NULL::"public"."domain__short_text" AS "name",
    NULL::"text" AS "description",
    NULL::timestamp with time zone AS "created_at",
    NULL::"uuid" AS "created_by",
    NULL::bigint AS "category_id",
    NULL::bigint AS "sub_brand_id",
    NULL::boolean AS "is_verified",
    NULL::"text" AS "logo_file",
    NULL::"uuid" AS "check_in_created_by",
    NULL::bigint AS "check_ins",
    NULL::numeric AS "average_rating";

ALTER TABLE "public"."view__profile_product_ratings" OWNER TO "postgres";

CREATE VIEW "public"."view__recent_locations_from_current_user" AS
 SELECT DISTINCT ON ("l"."id") "l"."id",
    "l"."country_code",
    "l"."name",
    "l"."title",
    "l"."longitude",
    "l"."latitude",
    "l"."created_by",
    "l"."created_at"
   FROM (("public"."profiles" "p"
     JOIN "public"."check_ins" "c" ON (("p"."id" = "c"."created_by")))
     JOIN "public"."locations" "l" ON (("c"."location_id" = "l"."id")))
  WHERE ("p"."id" = "auth"."uid"())
  ORDER BY "l"."id", "c"."check_in_at" DESC;

ALTER TABLE "public"."view__recent_locations_from_current_user" OWNER TO "postgres";

ALTER TABLE ONLY "public"."brand_edit_suggestions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."brand_edit_suggestions_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."check_in_tagged_profiles" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."check_in_tagged_profiles_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."company_edit_suggestions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."company_edit_suggestions_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."notifications" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."notifications_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."permissions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."permissions_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."product_barcodes" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_barcodes_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_edit_suggestion_subcategories_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."product_edit_suggestions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_edit_suggestions_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."product_variants" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_variants_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."reports" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."reports_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."sub_brand_edit_suggestion_id_seq"'::"regclass");

ALTER TABLE ONLY "public"."brand_edit_suggestions"
    ADD CONSTRAINT "brand_edit_suggestions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brand_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_brand_owner_id_name_key" UNIQUE ("brand_owner_id", "name");

ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_name_key" UNIQUE ("name");

ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."category_serving_styles"
    ADD CONSTRAINT "category_serving_styles_pkey" PRIMARY KEY ("category_id", "serving_style_id");

ALTER TABLE ONLY "public"."check_in_comments"
    ADD CONSTRAINT "check_in_comments_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."check_in_flavors"
    ADD CONSTRAINT "check_in_flavors_check_in_id_flavor_id_key" UNIQUE ("check_in_id", "flavor_id");

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "check_in_reactions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."check_in_tagged_profiles"
    ADD CONSTRAINT "check_in_tagged_profiles_check_in_id_profile_id_key" UNIQUE ("check_in_id", "profile_id");

ALTER TABLE ONLY "public"."check_in_tagged_profiles"
    ADD CONSTRAINT "check_in_tagged_profiles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_name_key" UNIQUE ("name");

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."company_edit_suggestions"
    ADD CONSTRAINT "company_edit_suggestions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."countries"
    ADD CONSTRAINT "countries_pkey" PRIMARY KEY ("country_code");

ALTER TABLE ONLY "public"."documents"
    ADD CONSTRAINT "documents_pkey" PRIMARY KEY ("page_name");

ALTER TABLE ONLY "public"."flavors"
    ADD CONSTRAINT "flavors_name_key" UNIQUE ("name");

ALTER TABLE ONLY "public"."flavors"
    ADD CONSTRAINT "flavors_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_user_id_1_user_id_2_key" UNIQUE ("user_id_1", "user_id_2");

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_name_longitude_latitude_country_code_key" UNIQUE ("name", "longitude", "latitude", "country_code");

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_name_longitude_latitude_country_code_key1" UNIQUE ("name", "longitude", "latitude", "country_code");

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pk" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "one_reaction_per_user" UNIQUE ("check_in_id", "created_by");

ALTER TABLE ONLY "public"."product_barcodes"
    ADD CONSTRAINT "product_barcodes_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."product_duplicate_suggestions"
    ADD CONSTRAINT "product_duplicate_suggestion_pkey" PRIMARY KEY ("product_id", "duplicate_of_product_id", "created_by");

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories"
    ADD CONSTRAINT "product_edit_suggestion_subcategories_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "product_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_pk" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_manufacturer_id_key" UNIQUE ("product_id", "manufacturer_id");

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_pkey" PRIMARY KEY ("product_id", "subcategory_id");

ALTER TABLE ONLY "public"."profile_push_notifications"
    ADD CONSTRAINT "profile_push_notification_token_firebase_registration_token_key" UNIQUE ("firebase_registration_token");

ALTER TABLE ONLY "public"."profile_push_notifications"
    ADD CONSTRAINT "profile_push_notification_tokens_pkey" PRIMARY KEY ("firebase_registration_token");

ALTER TABLE ONLY "public"."profile_settings"
    ADD CONSTRAINT "profile_settings_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."profiles_roles"
    ADD CONSTRAINT "profiles_roles_pkey" PRIMARY KEY ("profile_id", "role_id");

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "role_permission_pk" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_name_key" UNIQUE ("name");

ALTER TABLE ONLY "public"."roles_permissions"
    ADD CONSTRAINT "roles_permissions_pkey" PRIMARY KEY ("role_id", "permission_id");

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."secrets"
    ADD CONSTRAINT "secrets_pk" PRIMARY KEY ("supabase_anon_key");

ALTER TABLE ONLY "public"."serving_styles"
    ADD CONSTRAINT "serving_styles_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brand_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brands_brand_id_name_key" UNIQUE ("brand_id", "name");

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_category_id_name_key" UNIQUE ("category_id", "name");

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."product_barcodes"
    ADD CONSTRAINT "unique_barcode_type_product" UNIQUE ("product_id", "barcode", "type");

ALTER TABLE ONLY "public"."company_edit_suggestions"
    ADD CONSTRAINT "unique_company_edit_suggestion" UNIQUE ("company_id", "name", "created_by");

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "unique_product_subcategory" UNIQUE ("product_id", "subcategory_id");

CREATE INDEX "brand_name_idx" ON "public"."products" USING "gist" (COALESCE(("name")::"text", "description") "public"."gist_trgm_ops");

CREATE INDEX "check_ins_created_at_idx" ON "public"."check_ins" USING "btree" ("created_at");

CREATE INDEX "product_description_idx" ON "public"."products" USING "gist" ("description" "public"."gist_trgm_ops");

CREATE INDEX "product_name_idx" ON "public"."products" USING "gist" ("name" "public"."gist_trgm_ops");

CREATE INDEX "sub_brand_name_idx" ON "public"."sub_brands" USING "gist" ("name" "public"."gist_trgm_ops");

CREATE UNIQUE INDEX "unique_products" ON "public"."products" USING "btree" ("lower"(("name")::"text"), "description", "category_id", "sub_brand_id");

CREATE UNIQUE INDEX "unique_sub_brands" ON "public"."sub_brands" USING "btree" ("name", "brand_id") WHERE ("name" IS NOT NULL);

CREATE UNIQUE INDEX "unique_sub_brands_where_null" ON "public"."sub_brands" USING "btree" ("brand_id") WHERE ("name" IS NULL);

CREATE OR REPLACE VIEW "public"."view__brand_ratings" AS
 SELECT "b"."id",
    "b"."name",
    "b"."brand_owner_id",
    "b"."created_at",
    "b"."created_by",
    "b"."is_verified",
    "b"."logo_file",
    "count"("ci"."id") AS "total_check_ins",
    "round"("avg"(("ci"."rating")::numeric), 2) AS "average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_by" IN ( SELECT "view__current_user_friends"."id"
           FROM "public"."view__current_user_friends"))) AS "friends_check_ins",
    "round"("avg"(("ci"."rating")::numeric) FILTER (WHERE ("ci"."created_by" IN ( SELECT "view__current_user_friends"."id"
           FROM "public"."view__current_user_friends"))), 2) AS "friends_average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_by" = "auth"."uid"())) AS "current_user_check_ins",
    "round"("avg"(("ci"."rating")::numeric) FILTER (WHERE ("ci"."created_by" = "auth"."uid"())), 2) AS "current_user_average_rating"
   FROM ((("public"."brands" "b"
     LEFT JOIN "public"."sub_brands" "sb" ON (("b"."id" = "sb"."brand_id")))
     LEFT JOIN "public"."products" "p" ON (("p"."sub_brand_id" = "sb"."id")))
     LEFT JOIN "public"."check_ins" "ci" ON (("p"."id" = "ci"."product_id")))
  GROUP BY "b"."id";

CREATE OR REPLACE VIEW "public"."view__search_product_ratings" AS
 SELECT "p"."id",
    "p"."name",
    "p"."description",
    "p"."created_at",
    "p"."created_by",
    "p"."category_id",
    "p"."sub_brand_id",
    "p"."logo_file",
    "p"."is_verified",
    "to_tsvector"(((((COALESCE(("b"."name")::"text", ''::"text") || ' '::"text") || COALESCE(("sb"."name")::"text", ''::"text")) || ' '::"text") || COALESCE(("p"."name")::"text", ''::"text"))) AS "search_value",
    "count"("ci"."id") AS "total_check_ins",
    "round"("avg"(("ci"."rating")::numeric), 2) AS "average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_by" IN ( SELECT "view__current_user_friends"."id"
           FROM "public"."view__current_user_friends"))) AS "friends_check_ins",
    "round"("avg"(("ci"."rating")::numeric) FILTER (WHERE ("ci"."created_by" IN ( SELECT "view__current_user_friends"."id"
           FROM "public"."view__current_user_friends"))), 2) AS "friends_average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_by" = "auth"."uid"())) AS "current_user_check_ins",
    "round"("avg"(("ci"."rating")::numeric) FILTER (WHERE ("ci"."created_by" = "auth"."uid"())), 2) AS "current_user_average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_at" > ("now"() - '1 mon'::interval))) AS "check_ins_during_previous_month"
   FROM ((("public"."products" "p"
     LEFT JOIN "public"."check_ins" "ci" ON (("p"."id" = "ci"."product_id")))
     LEFT JOIN "public"."sub_brands" "sb" ON (("sb"."id" = "p"."sub_brand_id")))
     LEFT JOIN "public"."brands" "b" ON (("sb"."brand_id" = "b"."id")))
  GROUP BY "p"."id", "p"."name", "p"."description", "p"."created_at", "p"."created_by", "p"."category_id", "p"."sub_brand_id", "p"."is_verified", ("to_tsvector"(((((COALESCE(("b"."name")::"text", ''::"text") || ' '::"text") || COALESCE(("sb"."name")::"text", ''::"text")) || ' '::"text") || COALESCE(("p"."name")::"text", ''::"text"))));

CREATE OR REPLACE VIEW "public"."view__product_ratings" AS
 SELECT "p"."id",
    "p"."name",
    "p"."description",
    "p"."created_at",
    "p"."created_by",
    "p"."category_id",
    "p"."sub_brand_id",
    "p"."is_verified",
    "p"."logo_file",
    "count"("ci"."id") AS "total_check_ins",
    "round"("avg"(("ci"."rating")::numeric), 2) AS "average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_by" IN ( SELECT "view__current_user_friends"."id"
           FROM "public"."view__current_user_friends"))) AS "friends_check_ins",
    "round"("avg"(("ci"."rating")::numeric) FILTER (WHERE ("ci"."created_by" IN ( SELECT "view__current_user_friends"."id"
           FROM "public"."view__current_user_friends"))), 2) AS "friends_average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_by" = "auth"."uid"())) AS "current_user_check_ins",
    "round"("avg"(("ci"."rating")::numeric) FILTER (WHERE ("ci"."created_by" = "auth"."uid"())), 2) AS "current_user_average_rating",
    "count"("ci"."id") FILTER (WHERE ("ci"."created_at" > ("now"() - '1 mon'::interval))) AS "check_ins_during_previous_month"
   FROM ("public"."products" "p"
     LEFT JOIN "public"."check_ins" "ci" ON (("p"."id" = "ci"."product_id")))
  GROUP BY "p"."id";

CREATE OR REPLACE VIEW "public"."view__profile_product_ratings" AS
 SELECT "p"."id",
    "p"."name",
    "p"."description",
    "p"."created_at",
    "p"."created_by",
    "p"."category_id",
    "p"."sub_brand_id",
    "p"."is_verified",
    "p"."logo_file",
    "ci"."created_by" AS "check_in_created_by",
    "count"("p"."id") AS "check_ins",
    "round"("avg"(("ci"."rating")::numeric), 2) AS "average_rating"
   FROM (("public"."products" "p"
     LEFT JOIN "public"."check_ins" "ci" ON (("p"."id" = "ci"."product_id")))
     LEFT JOIN "public"."profiles" "pr" ON (("ci"."created_by" = "pr"."id")))
  GROUP BY "p"."id", "pr"."id", "ci"."created_by";

CREATE TRIGGER "add_default_role_for_user" AFTER INSERT ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__add_user_role"();

CREATE TRIGGER "add_options_for_profile" AFTER INSERT ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__create_profile_settings"();

CREATE TRIGGER "always_update_as_current_user" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__use_current_user_profile_id_as_id"();

CREATE TRIGGER "check_if_insert_or_update_is_allowed" BEFORE INSERT OR UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__friend_request_check"();

CREATE TRIGGER "check_subcategory_constraint" BEFORE INSERT OR UPDATE ON "public"."products_subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__check_subcategory_constraint"();

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."product_variants" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."products_subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();

CREATE TRIGGER "clean_up" BEFORE INSERT OR UPDATE ON "public"."check_ins" FOR EACH ROW EXECUTE FUNCTION "public"."tg__clean_up_check_in"();

CREATE TRIGGER "clean_up_updates" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__clean_up_profile_values"();

CREATE TRIGGER "create_default_sub_brand" AFTER INSERT ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__create_default_sub_brand"();

CREATE TRIGGER "delete_notification_trigger" AFTER UPDATE OF "deleted_at" ON "public"."check_in_reactions" FOR EACH ROW WHEN (("old"."deleted_at" IS DISTINCT FROM "new"."deleted_at")) EXECUTE FUNCTION "public"."delete_notification_on_reaction_delete"();

CREATE TRIGGER "delete_unused_tokens" AFTER INSERT ON "public"."profile_push_notifications" FOR EACH STATEMENT EXECUTE FUNCTION "public"."tg__remove_unused_tokens"();

CREATE TRIGGER "forbid_send_messages_too_often" BEFORE INSERT ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__forbid_send_messages_too_often"();

CREATE TRIGGER "forbid_tagging_users_that_are_not_friends" BEFORE INSERT ON "public"."check_in_tagged_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__must_be_friends"();

CREATE TRIGGER "make_check_in_id_immutable" BEFORE UPDATE ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__forbid_changing_check_in_id"();

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."check_ins" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();

CREATE TRIGGER "on_friend_request_update" BEFORE INSERT OR UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__check_friend_status_transition"();

CREATE TRIGGER "send_notification_on_being_tagged_on_check_in" AFTER INSERT ON "public"."check_in_tagged_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_tagged_in_check_in_notification"();

CREATE TRIGGER "send_notification_on_insert" AFTER INSERT ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_check_in_comment_notification"();

CREATE TRIGGER "send_notification_on_insert" AFTER INSERT ON "public"."check_in_reactions" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_check_in_reaction_notification"();

CREATE TRIGGER "send_notification_on_insert" AFTER INSERT ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_friend_request_notification"();

CREATE TRIGGER "send_push_notification" AFTER INSERT ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_push_notification"();

CREATE TRIGGER "stamp_created_at" BEFORE INSERT OR UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_at"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."check_in_reactions" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."check_ins" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."company_edit_suggestions" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."locations" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."product_barcodes" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."product_duplicate_suggestions" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."product_edit_suggestions" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."product_variants" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."products_subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."profile_push_notifications" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."reports" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();

CREATE TRIGGER "stamp_updated_at" BEFORE INSERT OR UPDATE ON "public"."profile_push_notifications" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_updated_at"();

CREATE TRIGGER "trim_description_empty_check" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_description_empty_check"();

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();

CREATE TRIGGER "update_notification_badges" AFTER INSERT OR DELETE OR UPDATE ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."tg__update_notification_badges"();

CREATE TRIGGER "use_current_user_id_as_id" BEFORE UPDATE ON "public"."profile_settings" FOR EACH ROW EXECUTE FUNCTION "public"."tg__use_current_user_profile_id_as_id"();

ALTER TABLE ONLY "public"."brand_edit_suggestions"
    ADD CONSTRAINT "brand_edit_suggestions_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."brand_edit_suggestions"
    ADD CONSTRAINT "brand_edit_suggestions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_brand_owner_id_fkey" FOREIGN KEY ("brand_owner_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."category_serving_styles"
    ADD CONSTRAINT "category_serving_styles_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."category_serving_styles"
    ADD CONSTRAINT "category_serving_styles_serving_style_id_fkey" FOREIGN KEY ("serving_style_id") REFERENCES "public"."serving_styles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_comments"
    ADD CONSTRAINT "check_in_comments_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_comments"
    ADD CONSTRAINT "check_in_comments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_flavors"
    ADD CONSTRAINT "check_in_flavors_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_flavors"
    ADD CONSTRAINT "check_in_flavors_flavor_id_fkey" FOREIGN KEY ("flavor_id") REFERENCES "public"."flavors"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "check_in_reactions_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "check_in_reactions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "check_in_tagged_profile_id" FOREIGN KEY ("tagged_in_check_in_id") REFERENCES "public"."check_in_tagged_profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_tagged_profiles"
    ADD CONSTRAINT "check_in_tagged_profiles_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_in_tagged_profiles"
    ADD CONSTRAINT "check_in_tagged_profiles_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."locations"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_product_variant_id_fkey" FOREIGN KEY ("product_variant_id") REFERENCES "public"."product_variants"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_purchase_location_id_fkey" FOREIGN KEY ("purchase_location_id") REFERENCES "public"."locations"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_serving_style_id_fkey" FOREIGN KEY ("serving_style_id") REFERENCES "public"."serving_styles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_subsidiary_of_fkey" FOREIGN KEY ("subsidiary_of") REFERENCES "public"."companies"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."company_edit_suggestions"
    ADD CONSTRAINT "company_edit_suggestions_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."company_edit_suggestions"
    ADD CONSTRAINT "company_edit_suggestions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_blocked_by_fkey" FOREIGN KEY ("blocked_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_user_id_1_fkey" FOREIGN KEY ("user_id_1") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_user_id_2_fkey" FOREIGN KEY ("user_id_2") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_countries_fk" FOREIGN KEY ("country_code") REFERENCES "public"."countries"("country_code") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_check_in_comment_id_fkey" FOREIGN KEY ("check_in_comment_id") REFERENCES "public"."check_in_comments"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_check_in_reaction_id_fkey" FOREIGN KEY ("check_in_reaction_id") REFERENCES "public"."check_in_reactions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_friend_request_id_fkey" FOREIGN KEY ("friend_request_id") REFERENCES "public"."friends"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_barcodes"
    ADD CONSTRAINT "product_barcodes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."product_barcodes"
    ADD CONSTRAINT "product_barcodes_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_duplicate_suggestions"
    ADD CONSTRAINT "product_duplicate_suggestion_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_duplicate_suggestions"
    ADD CONSTRAINT "product_duplicate_suggestion_duplicate_of_product_id_fkey" FOREIGN KEY ("duplicate_of_product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_duplicate_suggestions"
    ADD CONSTRAINT "product_duplicate_suggestion_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories"
    ADD CONSTRAINT "product_edit_suggestion_subcate_product_edit_suggestion_id_fkey" FOREIGN KEY ("product_edit_suggestion_id") REFERENCES "public"."product_edit_suggestions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories"
    ADD CONSTRAINT "product_edit_suggestion_subcategories_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategories"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_sub_brand_id_fkey" FOREIGN KEY ("sub_brand_id") REFERENCES "public"."sub_brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_manufacturer_id_fkey" FOREIGN KEY ("manufacturer_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_sub_brands__fk" FOREIGN KEY ("sub_brand_id") REFERENCES "public"."sub_brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategories"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profile_push_notifications"
    ADD CONSTRAINT "profile_push_notification_tokens_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profile_settings"
    ADD CONSTRAINT "profile_settings_id_fkey" FOREIGN KEY ("id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profiles_roles"
    ADD CONSTRAINT "profiles_roles_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."profiles_roles"
    ADD CONSTRAINT "profiles_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_check_in_comment_id_fkey" FOREIGN KEY ("check_in_comment_id") REFERENCES "public"."check_in_comments"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."reports"
    ADD CONSTRAINT "reports_sub_brand_id_fkey" FOREIGN KEY ("sub_brand_id") REFERENCES "public"."sub_brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."roles_permissions"
    ADD CONSTRAINT "roles_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "public"."permissions"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."roles_permissions"
    ADD CONSTRAINT "roles_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_sub_brand_id_fkey" FOREIGN KEY ("sub_brand_id") REFERENCES "public"."sub_brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brands_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brands_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id");

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

CREATE POLICY "Allow deleting for users with permission" ON "public"."brand_edit_suggestions" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));

CREATE POLICY "Allow deleting for users with permission" ON "public"."company_edit_suggestions" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));

CREATE POLICY "Allow deleting for users with permission" ON "public"."product_edit_suggestion_subcategories" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));

CREATE POLICY "Allow deleting for users with permission" ON "public"."product_edit_suggestions" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));

CREATE POLICY "Allow deleting for users with permission" ON "public"."sub_brand_edit_suggestion" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));

CREATE POLICY "Categories are viewable by everyone." ON "public"."categories" FOR SELECT USING (true);

CREATE POLICY "Check in comments are viewable by everyone." ON "public"."check_in_comments" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Check in reactions are viewable by everyone unless soft-deleted" ON "public"."check_in_reactions" FOR SELECT TO "authenticated" USING (("deleted_at" IS NULL));

CREATE POLICY "Companies are viewable by everyone." ON "public"."companies" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable delete for both sides of friend status" ON "public"."friends" FOR DELETE TO "authenticated" USING (((("user_id_1" = "auth"."uid"()) OR ("user_id_2" = "auth"."uid"())) AND (("status" <> 'blocked'::"public"."enum__friend_status") OR ("blocked_by" = "auth"."uid"()))));

CREATE POLICY "Enable delete for creator" ON "public"."brand_edit_suggestions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for creator" ON "public"."check_in_comments" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for creator" ON "public"."company_edit_suggestions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for creator" ON "public"."product_duplicate_suggestions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for creator" ON "public"."product_edit_suggestion_subcategories" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."product_edit_suggestion_subcategories" "pess"
     LEFT JOIN "public"."product_edit_suggestions" "pes" ON (("pess"."product_edit_suggestion_id" = "pes"."id")))
  WHERE ("pes"."created_by" = "auth"."uid"()))));

CREATE POLICY "Enable delete for creator" ON "public"."product_edit_suggestions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for creator" ON "public"."sub_brand_edit_suggestion" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for creator of the check in" ON "public"."check_in_tagged_profiles" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_tagged_profiles"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));

CREATE POLICY "Enable delete for owner" ON "public"."profile_push_notifications" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for the creator" ON "public"."check_ins" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable delete for the creator of the check in" ON "public"."check_in_flavors" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_flavors"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));

CREATE POLICY "Enable delete for the owner" ON "public"."notifications" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "profile_id"));

CREATE POLICY "Enable delete for users with permission" ON "public"."brands" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_brands'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."category_serving_styles" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_serving_styles'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."companies" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_companies'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."flavors" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_flavors'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."locations" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_locations'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."product_variants" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_products'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."products" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_products'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."products_subcategories" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_products'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."serving_styles" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_serving_styles'::"text"));

CREATE POLICY "Enable delete for users with permission" ON "public"."sub_brands" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_brands'::"text"));

CREATE POLICY "Enable delete for users with permissions" ON "public"."product_barcodes" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_barcodes'::"text"));

CREATE POLICY "Enable insert for authenticated users" ON "public"."products_subcategories" FOR INSERT TO "authenticated" WITH CHECK (("created_by" = "auth"."uid"()));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."brand_edit_suggestions" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."check_in_comments" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."check_in_reactions" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."company_edit_suggestions" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."locations" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_duplicate_suggestions" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_edit_suggestion_subcategories" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_edit_suggestions" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_variants" FOR INSERT TO "authenticated" WITH CHECK (("created_by" = "auth"."uid"()));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."products" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."profile_push_notifications" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."reports" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."sub_brand_edit_suggestion" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."sub_brands" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for creator of  the check in" ON "public"."check_in_tagged_profiles" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_tagged_profiles"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));

CREATE POLICY "Enable insert for creator of the check in" ON "public"."check_in_flavors" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_flavors"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));

CREATE POLICY "Enable insert for users with permission" ON "public"."brands" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_create_brands'::"text"));

CREATE POLICY "Enable insert for users with permission" ON "public"."categories" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_add_categories'::"text"));

CREATE POLICY "Enable insert for users with permission" ON "public"."category_serving_styles" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_add_serving_styles'::"text"));

CREATE POLICY "Enable insert for users with permission" ON "public"."flavors" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_insert_flavors'::"text"));

CREATE POLICY "Enable insert for users with permission" ON "public"."product_barcodes" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_add_barcodes'::"text"));

CREATE POLICY "Enable insert for users with permission" ON "public"."products_subcategories" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_add_subcategories'::"text"));

CREATE POLICY "Enable insert for users with permission" ON "public"."serving_styles" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_add_serving_styles'::"text"));

CREATE POLICY "Enable insert for users with permission" ON "public"."subcategories" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_add_subcategories'::"text"));

CREATE POLICY "Enable insert for users with permissions" ON "public"."check_ins" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_create_check_ins'::"text"));

CREATE POLICY "Enable insert for users with permissions" ON "public"."companies" FOR INSERT TO "authenticated" WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_create_companies'::"text"));

CREATE POLICY "Enable insert for users with permissions" ON "public"."friends" FOR INSERT TO "authenticated" WITH CHECK ((("user_id_1" = "auth"."uid"()) AND "public"."fnc__has_permission"("auth"."uid"(), 'can_send_friend_requests'::"text")));

CREATE POLICY "Enable read access for all users" ON "public"."brand_edit_suggestions" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."brands" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."category_serving_styles" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."check_in_flavors" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."check_in_tagged_profiles" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."company_edit_suggestions" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."countries" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."documents" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."flavors" FOR SELECT USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."friends" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."locations" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."product_barcodes" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."product_edit_suggestion_subcategories" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."product_edit_suggestions" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."product_variants" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."products_subcategories" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."serving_styles" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for all users" ON "public"."sub_brand_edit_suggestion" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for creator" ON "public"."product_duplicate_suggestions" FOR SELECT TO "authenticated" USING (("created_by" = "auth"."uid"()));

CREATE POLICY "Enable read access for intended user" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("profile_id" = "auth"."uid"()));

CREATE POLICY "Enable read access for owner" ON "public"."profile_push_notifications" FOR SELECT TO "authenticated" USING (("created_by" = "auth"."uid"()));

CREATE POLICY "Enable read access for users with permissions" ON "public"."reports" FOR SELECT TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_read_reports'::"text"));

CREATE POLICY "Enable read access only to the owner" ON "public"."profile_settings" FOR SELECT TO "authenticated" USING (("id" = "auth"."uid"()));

CREATE POLICY "Enable read based on check in's creator's privacy settings" ON "public"."check_ins" FOR SELECT TO "authenticated" USING ("public"."fnc__user_can_view_check_in"("auth"."uid"(), "id"));

CREATE POLICY "Enable select for authenticated users only" ON "public"."permissions" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable select for authenticated users only" ON "public"."profiles_roles" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable select for authenticated users only" ON "public"."roles_permissions" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable update for both sides of friend status " ON "public"."friends" FOR UPDATE TO "authenticated" USING ((("user_id_1" = "auth"."uid"()) OR ("user_id_2" = "auth"."uid"()))) WITH CHECK ((("user_id_1" = "auth"."uid"()) OR ("user_id_2" = "auth"."uid"())));

CREATE POLICY "Enable update for creator of comment" ON "public"."check_in_comments" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "created_by")) WITH CHECK (("auth"."uid"() = "created_by"));

CREATE POLICY "Enable update for owner" ON "public"."profile_push_notifications" FOR UPDATE TO "authenticated" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));

CREATE POLICY "Enable update for owner" ON "public"."profile_settings" FOR UPDATE USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));

CREATE POLICY "Enable update for the creator" ON "public"."check_ins" FOR UPDATE TO "authenticated" USING (("created_by" = "auth"."uid"()));

CREATE POLICY "Enable update for users with permission" ON "public"."brands" FOR UPDATE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_edit_brands'::"text"));

CREATE POLICY "Enable update for users with permission" ON "public"."category_serving_styles" FOR UPDATE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_edit_serving_styles'::"text"));

CREATE POLICY "Enable update for users with permission" ON "public"."companies" FOR UPDATE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_edit_companies'::"text")) WITH CHECK ("public"."fnc__has_permission"("auth"."uid"(), 'can_edit_companies'::"text"));

CREATE POLICY "Enable update for users with permission" ON "public"."flavors" FOR UPDATE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_update_flavors'::"text"));

CREATE POLICY "Enable update for users with permission" ON "public"."serving_styles" FOR UPDATE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_edit_serving_styles'::"text"));

CREATE POLICY "Enable update for users with permission" ON "public"."sub_brands" FOR UPDATE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_update_sub_brands'::"text"));

CREATE POLICY "Enable update for users with permission" ON "public"."subcategories" FOR UPDATE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_edit_subcategories'::"text"));

CREATE POLICY "Forbid deleting verified" ON "public"."brands" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));

CREATE POLICY "Forbid deleting verified" ON "public"."companies" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));

CREATE POLICY "Forbid deleting verified" ON "public"."product_variants" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));

CREATE POLICY "Forbid deleting verified" ON "public"."products" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));

CREATE POLICY "Forbid deleting verified" ON "public"."sub_brands" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));

CREATE POLICY "Forbid deleting verified" ON "public"."subcategories" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));

CREATE POLICY "Products are viewable by everyone." ON "public"."products" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Public profiles are viewable by everyone." ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Sub-brands are viewable by everyone." ON "public"."sub_brands" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Subcategories are viewable by everyone." ON "public"."subcategories" FOR SELECT USING (true);

CREATE POLICY "Users can delete own profile." ON "public"."profiles" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "id"));

CREATE POLICY "Users can update own profile." ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));

ALTER TABLE "public"."brand_edit_suggestions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."brands" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."category_serving_styles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."check_in_comments" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."check_in_flavors" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."check_in_reactions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."check_in_tagged_profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."check_ins" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."companies" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."company_edit_suggestions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."countries" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."documents" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."flavors" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."friends" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."locations" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."permissions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."product_barcodes" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."product_duplicate_suggestions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."product_edit_suggestion_subcategories" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."product_edit_suggestions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."product_variants" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."products_subcategories" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profile_push_notifications" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profile_settings" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles_roles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."reports" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."roles_permissions" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."secrets" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."serving_styles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."sub_brand_edit_suggestion" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."sub_brands" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."subcategories" ENABLE ROW LEVEL SECURITY;

REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT ALL ON SCHEMA "public" TO PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

GRANT ALL ON FUNCTION "public"."citextin"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."citextin"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextin"("cstring") TO "service_role";

GRANT ALL ON FUNCTION "public"."citextout"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citextout"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextout"("public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citextrecv"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."citextrecv"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextrecv"("internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."citextsend"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citextsend"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextsend"("public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext"(boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."citext"(boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext"(boolean) TO "service_role";

GRANT ALL ON FUNCTION "public"."citext"(character) TO "anon";
GRANT ALL ON FUNCTION "public"."citext"(character) TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext"(character) TO "service_role";

GRANT ALL ON FUNCTION "public"."citext"("inet") TO "anon";
GRANT ALL ON FUNCTION "public"."citext"("inet") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext"("inet") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_cmp"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_cmp"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_cmp"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_eq"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_eq"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_eq"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_ge"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_ge"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_ge"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_gt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_gt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_gt"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_hash"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_hash"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_hash"("public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_hash_extended"("public"."citext", bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."citext_hash_extended"("public"."citext", bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_hash_extended"("public"."citext", bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_larger"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_larger"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_larger"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_le"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_le"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_le"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_lt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_lt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_lt"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_ne"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_ne"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_ne"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_pattern_cmp"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_cmp"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_cmp"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_pattern_ge"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_ge"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_ge"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_pattern_gt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_gt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_gt"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_pattern_le"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_le"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_le"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_pattern_lt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_lt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_lt"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."citext_smaller"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_smaller"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_smaller"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."delete_notification_on_reaction_delete"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_notification_on_reaction_delete"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_notification_on_reaction_delete"() TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__accept_friend_request"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__accept_friend_request"("user_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__check_if_username_is_available"("p_username" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__check_if_username_is_available"("p_username" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__check_if_username_is_available"("p_username" "text") TO "service_role";

GRANT ALL ON TABLE "public"."check_ins" TO "authenticated";
GRANT ALL ON TABLE "public"."check_ins" TO "anon";
GRANT ALL ON TABLE "public"."check_ins" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."check_in_reactions" TO "anon";
GRANT ALL ON TABLE "public"."check_in_reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_reactions" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__create_check_in_reaction"("p_check_in_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__create_check_in_reaction"("p_check_in_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_check_in_reaction"("p_check_in_id" bigint) TO "service_role";

GRANT ALL ON TABLE "public"."company_edit_suggestions" TO "anon";
GRANT ALL ON TABLE "public"."company_edit_suggestions" TO "authenticated";
GRANT ALL ON TABLE "public"."company_edit_suggestions" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__create_company_edit_suggestion"("p_company_id" bigint, "p_name" "text", "p_logo_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_company_edit_suggestion"("p_company_id" bigint, "p_name" "text", "p_logo_url" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__create_deeplink"("p_type" "text", "p_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__create_deeplink"("p_type" "text", "p_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_deeplink"("p_type" "text", "p_id" "text") TO "service_role";

GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint, "p_barcode_type" "text", "p_barcode_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint, "p_barcode_type" "text", "p_barcode_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint, "p_barcode_type" "text", "p_barcode_code" "text") TO "service_role";

GRANT ALL ON TABLE "public"."product_edit_suggestions" TO "anon";
GRANT ALL ON TABLE "public"."product_edit_suggestions" TO "authenticated";
GRANT ALL ON TABLE "public"."product_edit_suggestions" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__delete_check_in_as_moderator"("p_check_in_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__delete_check_in_as_moderator"("p_check_in_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__delete_check_in_as_moderator"("p_check_in_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__delete_check_in_comment_as_moderator"("p_check_in_comment_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__delete_check_in_comment_as_moderator"("p_check_in_comment_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__delete_check_in_comment_as_moderator"("p_check_in_comment_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__delete_current_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__delete_current_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__edit_product"("p_product_id" bigint, "p_name" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint, "p_description" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__edit_product"("p_product_id" bigint, "p_name" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint, "p_description" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__edit_product"("p_product_id" bigint, "p_name" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint, "p_description" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__export_data"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__export_data"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__export_data"() TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_activity_feed"("p_created_after" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_activity_feed"("p_created_after" "date") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_category_stats"("p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_category_stats"("p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_category_stats"("p_user_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_comment_notification"("p_check_in_comment_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_comment_notification"("p_check_in_comment_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_comment_notification"("p_check_in_comment_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_contributions_by_user"("p_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_contributions_by_user"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_contributions_by_user"("p_uid" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_current_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_current_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_current_profile"() TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_authorization_header"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_authorization_header"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_authorization_header"() TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) TO "service_role";

GRANT ALL ON TABLE "public"."locations" TO "anon";
GRANT ALL ON TABLE "public"."locations" TO "authenticated";
GRANT ALL ON TABLE "public"."locations" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_location_insert_if_not_exist"("p_name" "text", "p_title" "text", "p_latitude" numeric, "p_longitude" numeric, "p_country_code" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_location_insert_if_not_exist"("p_name" "text", "p_title" "text", "p_latitude" numeric, "p_longitude" numeric, "p_country_code" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_location_insert_if_not_exist"("p_name" "text", "p_title" "text", "p_latitude" numeric, "p_longitude" numeric, "p_country_code" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_location_suggestions"("p_longitude" double precision, "p_latitude" double precision) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_location_suggestions"("p_longitude" double precision, "p_latitude" double precision) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_location_suggestions"("p_longitude" double precision, "p_latitude" double precision) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_location_summary"("p_location_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_location_summary"("p_location_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_location_summary"("p_location_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_profile_summary"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_profile_summary"("p_uid" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_device_token" "text", "p_notification" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_device_token" "text", "p_notification" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_device_token" "text", "p_notification" "jsonb") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__get_subcategory_stats"("p_user_id" "uuid", "p_category_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_subcategory_stats"("p_user_id" "uuid", "p_category_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_subcategory_stats"("p_user_id" "uuid", "p_category_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__has_permission"("p_uid" "uuid", "p_permission_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__has_permission"("p_uid" "uuid", "p_permission_name" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__is_protected"("p_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__is_protected"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__is_protected"("p_uid" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__mark_all_notification_read"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__mark_all_notification_read"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__mark_all_notification_read"() TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__mark_check_in_notification_as_read"("p_check_in_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__mark_check_in_notification_as_read"("p_check_in_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__mark_check_in_notification_as_read"("p_check_in_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__mark_friend_request_notification_as_read"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__mark_friend_request_notification_as_read"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__mark_friend_request_notification_as_read"() TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__mark_notification_as_read"("p_notification_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__mark_notification_as_read"("p_notification_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__mark_notification_as_read"("p_notification_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__merge_locations"("p_location_id" "uuid", "p_to_location_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__merge_locations"("p_location_id" "uuid", "p_to_location_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__merge_locations"("p_location_id" "uuid", "p_to_location_id" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__refresh_firebase_access_token"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__refresh_firebase_access_token"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__refresh_firebase_access_token"() TO "service_role";

GRANT ALL ON TABLE "public"."view__search_product_ratings" TO "anon";
GRANT ALL ON TABLE "public"."view__search_product_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."view__search_product_ratings" TO "service_role";

GRANT ALL ON TABLE "public"."materialized_view__search_product_ratings" TO "anon";
GRANT ALL ON TABLE "public"."materialized_view__search_product_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."materialized_view__search_product_ratings" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__search_products"("p_search_term" "text", "p_only_non_checked_in" boolean, "p_category_name" "text", "p_subcategory_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__search_products"("p_search_term" "text", "p_only_non_checked_in" boolean, "p_category_name" "text", "p_subcategory_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__search_products"("p_search_term" "text", "p_only_non_checked_in" boolean, "p_category_name" "text", "p_subcategory_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__soft_delete_check_in_reaction"("p_check_in_reaction_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__soft_delete_check_in_reaction"("p_check_in_reaction_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__soft_delete_check_in_reaction"("p_check_in_reaction_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid", "p_blur_hash" "text", "p_check_in_at" timestamp with time zone, "p_purchase_location_id" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."profile_push_notifications" TO "anon";
GRANT ALL ON TABLE "public"."profile_push_notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_push_notifications" TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__user_can_view_check_in"("p_uid" "uuid", "p_check_in_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__user_can_view_check_in"("p_uid" "uuid", "p_check_in_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__user_can_view_check_in"("p_uid" "uuid", "p_check_in_id" bigint) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__user_is_friends_with"("p_uid" "uuid", "p_friend_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__user_is_friends_with"("p_uid" "uuid", "p_friend_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__user_is_friends_with"("p_uid" "uuid", "p_friend_uid" "uuid") TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__verify_brand"("p_brand_id" bigint, "p_is_verified" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__verify_brand"("p_brand_id" bigint, "p_is_verified" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__verify_brand"("p_brand_id" bigint, "p_is_verified" boolean) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__verify_company"("p_company_id" bigint, "p_is_verified" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__verify_company"("p_company_id" bigint, "p_is_verified" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__verify_company"("p_company_id" bigint, "p_is_verified" boolean) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__verify_product"("p_product_id" bigint, "p_is_verified" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__verify_product"("p_product_id" bigint, "p_is_verified" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__verify_product"("p_product_id" bigint, "p_is_verified" boolean) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__verify_sub_brand"("p_sub_brand_id" bigint, "p_is_verified" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__verify_sub_brand"("p_sub_brand_id" bigint, "p_is_verified" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__verify_sub_brand"("p_sub_brand_id" bigint, "p_is_verified" boolean) TO "service_role";

GRANT ALL ON FUNCTION "public"."fnc__verify_subcategory"("p_subcategory_id" bigint, "p_is_verified" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__verify_subcategory"("p_subcategory_id" bigint, "p_is_verified" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__verify_subcategory"("p_subcategory_id" bigint, "p_is_verified" boolean) TO "service_role";

GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."replace"("public"."citext", "public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."replace"("public"."citext", "public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."replace"("public"."citext", "public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "anon";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "service_role";

GRANT ALL ON FUNCTION "public"."show_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "service_role";

GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "service_role";

GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."split_part"("public"."citext", "public"."citext", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."split_part"("public"."citext", "public"."citext", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."split_part"("public"."citext", "public"."citext", integer) TO "service_role";

GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."strpos"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."strpos"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strpos"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__add_user_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__add_user_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__add_user_role"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__check_friend_status_transition"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__check_friend_status_transition"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__check_subcategory_constraint"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__check_subcategory_constraint"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__clean_up_check_in"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__clean_up_check_in"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__clean_up_check_in"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__clean_up_profile_values"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__clean_up_profile_values"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__clean_up_profile_values"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__create_default_sub_brand"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_default_sub_brand"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__create_friend_request"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_friend_request"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__create_profile_for_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_profile_for_new_user"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__create_profile_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_profile_settings"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__forbid_changing_check_in_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__forbid_changing_check_in_id"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__forbid_send_messages_too_often"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__forbid_send_messages_too_often"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__friend_request_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__friend_request_check"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__is_verified_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__is_verified_check"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__make_id_immutable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__make_id_immutable"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__must_be_friends"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__must_be_friends"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__refresh_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__refresh_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__refresh_updated_at"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__remove_unused_tokens"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__remove_unused_tokens"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__remove_unused_tokens"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__send_check_in_comment_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__send_check_in_comment_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_check_in_comment_notification"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__send_check_in_reaction_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_check_in_reaction_notification"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__send_friend_request_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_friend_request_notification"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__send_push_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__send_push_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_push_notification"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__send_tagged_in_check_in_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_tagged_in_check_in_notification"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__set_avatar_on_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__set_avatar_on_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__set_avatar_on_upload"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__set_brand_logo_on_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__set_brand_logo_on_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__set_brand_logo_on_upload"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__set_check_in_image_on_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__set_check_in_image_on_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__set_check_in_image_on_upload"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__set_company_logo_on_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__set_company_logo_on_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__set_company_logo_on_upload"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__set_product_logo_on_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__set_product_logo_on_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__set_product_logo_on_upload"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__stamp_created_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__stamp_created_at"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__stamp_created_by"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__stamp_created_by"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__stamp_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__stamp_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__stamp_updated_at"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__trim_description_empty_check"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__trim_description_empty_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__trim_description_empty_check"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__trim_name_empty_check"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__trim_name_empty_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__trim_name_empty_check"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__update_notification_badges"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__update_notification_badges"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__update_notification_badges"() TO "service_role";

GRANT ALL ON FUNCTION "public"."tg__use_current_user_profile_id_as_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__use_current_user_profile_id_as_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__use_current_user_profile_id_as_id"() TO "service_role";

GRANT ALL ON FUNCTION "public"."translate"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."translate"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."translate"("public"."citext", "public"."citext", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "service_role";

GRANT ALL ON FUNCTION "public"."max"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."max"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."max"("public"."citext") TO "service_role";

GRANT ALL ON FUNCTION "public"."min"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."min"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."min"("public"."citext") TO "service_role";

GRANT ALL ON TABLE "public"."brand_edit_suggestions" TO "anon";
GRANT ALL ON TABLE "public"."brand_edit_suggestions" TO "authenticated";
GRANT ALL ON TABLE "public"."brand_edit_suggestions" TO "service_role";

GRANT ALL ON SEQUENCE "public"."brand_edit_suggestions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."brand_edit_suggestions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."brand_edit_suggestions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."brands" TO "anon";
GRANT ALL ON TABLE "public"."brands" TO "authenticated";
GRANT ALL ON TABLE "public"."brands" TO "service_role";

GRANT ALL ON SEQUENCE "public"."brands_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."brands_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."brands_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."categories" TO "anon";
GRANT ALL ON TABLE "public"."categories" TO "authenticated";
GRANT ALL ON TABLE "public"."categories" TO "service_role";

GRANT ALL ON SEQUENCE "public"."categories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."categories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."categories_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."category_serving_styles" TO "anon";
GRANT ALL ON TABLE "public"."category_serving_styles" TO "authenticated";
GRANT ALL ON TABLE "public"."category_serving_styles" TO "service_role";

GRANT ALL ON TABLE "public"."check_in_comments" TO "anon";
GRANT ALL ON TABLE "public"."check_in_comments" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_comments" TO "service_role";

GRANT ALL ON SEQUENCE "public"."check_in_comments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."check_in_comments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."check_in_comments_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."check_in_flavors" TO "anon";
GRANT ALL ON TABLE "public"."check_in_flavors" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_flavors" TO "service_role";

GRANT ALL ON SEQUENCE "public"."check_in_reactions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."check_in_reactions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."check_in_reactions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."check_in_tagged_profiles" TO "anon";
GRANT ALL ON TABLE "public"."check_in_tagged_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_tagged_profiles" TO "service_role";

GRANT ALL ON SEQUENCE "public"."check_in_tagged_profiles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."check_in_tagged_profiles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."check_in_tagged_profiles_id_seq" TO "service_role";

GRANT ALL ON SEQUENCE "public"."check_ins_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."check_ins_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."check_ins_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."companies" TO "authenticated";
GRANT ALL ON TABLE "public"."companies" TO "anon";
GRANT ALL ON TABLE "public"."companies" TO "service_role";

GRANT ALL ON SEQUENCE "public"."companies_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."companies_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."companies_id_seq" TO "service_role";

GRANT ALL ON SEQUENCE "public"."company_edit_suggestions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."company_edit_suggestions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."company_edit_suggestions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."countries" TO "anon";
GRANT ALL ON TABLE "public"."countries" TO "authenticated";
GRANT ALL ON TABLE "public"."countries" TO "service_role";

GRANT ALL ON TABLE "public"."documents" TO "anon";
GRANT ALL ON TABLE "public"."documents" TO "authenticated";
GRANT ALL ON TABLE "public"."documents" TO "service_role";

GRANT ALL ON TABLE "public"."flavors" TO "anon";
GRANT ALL ON TABLE "public"."flavors" TO "authenticated";
GRANT ALL ON TABLE "public"."flavors" TO "service_role";

GRANT ALL ON SEQUENCE "public"."flavors_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."flavors_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."flavors_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."friends" TO "authenticated";
GRANT ALL ON TABLE "public"."friends" TO "anon";
GRANT ALL ON TABLE "public"."friends" TO "service_role";

GRANT ALL ON SEQUENCE "public"."friends_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."friends_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."friends_id_seq" TO "service_role";

GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."permissions" TO "anon";
GRANT ALL ON TABLE "public"."permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."permissions" TO "service_role";

GRANT ALL ON SEQUENCE "public"."permissions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."permissions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."permissions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."product_barcodes" TO "anon";
GRANT ALL ON TABLE "public"."product_barcodes" TO "authenticated";
GRANT ALL ON TABLE "public"."product_barcodes" TO "service_role";

GRANT ALL ON SEQUENCE "public"."product_barcodes_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_barcodes_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_barcodes_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."product_duplicate_suggestions" TO "anon";
GRANT ALL ON TABLE "public"."product_duplicate_suggestions" TO "authenticated";
GRANT ALL ON TABLE "public"."product_duplicate_suggestions" TO "service_role";

GRANT ALL ON TABLE "public"."product_edit_suggestion_subcategories" TO "anon";
GRANT ALL ON TABLE "public"."product_edit_suggestion_subcategories" TO "authenticated";
GRANT ALL ON TABLE "public"."product_edit_suggestion_subcategories" TO "service_role";

GRANT ALL ON SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" TO "service_role";

GRANT ALL ON SEQUENCE "public"."product_edit_suggestions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestions_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."product_variants" TO "authenticated";
GRANT ALL ON TABLE "public"."product_variants" TO "anon";
GRANT ALL ON TABLE "public"."product_variants" TO "service_role";

GRANT ALL ON SEQUENCE "public"."product_variants_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_variants_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_variants_id_seq" TO "service_role";

GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."products_subcategories" TO "anon";
GRANT ALL ON TABLE "public"."products_subcategories" TO "authenticated";
GRANT ALL ON TABLE "public"."products_subcategories" TO "service_role";

GRANT ALL ON SEQUENCE "public"."products_subcategories_product_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_subcategories_product_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_subcategories_product_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."profile_settings" TO "anon";
GRANT ALL ON TABLE "public"."profile_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_settings" TO "service_role";

GRANT ALL ON TABLE "public"."profiles_roles" TO "anon";
GRANT ALL ON TABLE "public"."profiles_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles_roles" TO "service_role";

GRANT ALL ON TABLE "public"."reports" TO "anon";
GRANT ALL ON TABLE "public"."reports" TO "authenticated";
GRANT ALL ON TABLE "public"."reports" TO "service_role";

GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."reports_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";

GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."roles_permissions" TO "anon";
GRANT ALL ON TABLE "public"."roles_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."roles_permissions" TO "service_role";

GRANT ALL ON TABLE "public"."secrets" TO "anon";
GRANT ALL ON TABLE "public"."secrets" TO "authenticated";
GRANT ALL ON TABLE "public"."secrets" TO "service_role";

GRANT ALL ON TABLE "public"."serving_styles" TO "anon";
GRANT ALL ON TABLE "public"."serving_styles" TO "authenticated";
GRANT ALL ON TABLE "public"."serving_styles" TO "service_role";

GRANT ALL ON SEQUENCE "public"."serving_styles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."serving_styles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."serving_styles_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."sub_brand_edit_suggestion" TO "anon";
GRANT ALL ON TABLE "public"."sub_brand_edit_suggestion" TO "authenticated";
GRANT ALL ON TABLE "public"."sub_brand_edit_suggestion" TO "service_role";

GRANT ALL ON SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."sub_brands" TO "anon";
GRANT ALL ON TABLE "public"."sub_brands" TO "authenticated";
GRANT ALL ON TABLE "public"."sub_brands" TO "service_role";

GRANT ALL ON SEQUENCE "public"."sub_brands_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."sub_brands_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."sub_brands_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."subcategories" TO "anon";
GRANT ALL ON TABLE "public"."subcategories" TO "authenticated";
GRANT ALL ON TABLE "public"."subcategories" TO "service_role";

GRANT ALL ON SEQUENCE "public"."subcategories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."subcategories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."subcategories_id_seq" TO "service_role";

GRANT ALL ON TABLE "public"."view__brand_ratings" TO "anon";
GRANT ALL ON TABLE "public"."view__brand_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."view__brand_ratings" TO "service_role";

GRANT ALL ON TABLE "public"."view__current_user_friends" TO "anon";
GRANT ALL ON TABLE "public"."view__current_user_friends" TO "authenticated";
GRANT ALL ON TABLE "public"."view__current_user_friends" TO "service_role";

GRANT ALL ON TABLE "public"."view__product_ratings" TO "anon";
GRANT ALL ON TABLE "public"."view__product_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."view__product_ratings" TO "service_role";

GRANT ALL ON TABLE "public"."view__profile_product_ratings" TO "anon";
GRANT ALL ON TABLE "public"."view__profile_product_ratings" TO "authenticated";
GRANT ALL ON TABLE "public"."view__profile_product_ratings" TO "service_role";

GRANT ALL ON TABLE "public"."view__recent_locations_from_current_user" TO "anon";
GRANT ALL ON TABLE "public"."view__recent_locations_from_current_user" TO "authenticated";
GRANT ALL ON TABLE "public"."view__recent_locations_from_current_user" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
