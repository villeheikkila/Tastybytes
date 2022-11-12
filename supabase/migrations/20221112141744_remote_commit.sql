--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.5 (Debian 14.5-2.pgdg110+2)

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

--
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "extensions";


--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";


--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "citext" WITH SCHEMA "public";


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "public";


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: domain__long_text; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN "public"."domain__long_text" AS "text"
	CONSTRAINT "long_text_check" CHECK ((("char_length"(VALUE) >= 1) AND ("char_length"(VALUE) <= 1024)));


ALTER DOMAIN "public"."domain__long_text" OWNER TO "postgres";

--
-- Name: domain__name; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN "public"."domain__name" AS "text"
	CONSTRAINT "name_check" CHECK ((("char_length"(VALUE) >= 2) AND ("char_length"(VALUE) <= 16)));


ALTER DOMAIN "public"."domain__name" OWNER TO "postgres";

--
-- Name: domain__rating; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN "public"."domain__rating" AS numeric
	CONSTRAINT "rating_value_check" CHECK (((VALUE >= (0)::numeric) AND (VALUE <= (5)::numeric)));


ALTER DOMAIN "public"."domain__rating" OWNER TO "postgres";

--
-- Name: domain__short_text; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN "public"."domain__short_text" AS "text"
	CONSTRAINT "short_text_check" CHECK ((("char_length"(VALUE) >= 1) AND ("char_length"(VALUE) <= 100)));


ALTER DOMAIN "public"."domain__short_text" OWNER TO "postgres";

--
-- Name: enum__color_scheme; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."enum__color_scheme" AS ENUM (
    'light',
    'dark',
    'system'
);


ALTER TYPE "public"."enum__color_scheme" OWNER TO "postgres";

--
-- Name: enum__friend_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."enum__friend_status" AS ENUM (
    'accepted',
    'pending',
    'blocked'
);


ALTER TYPE "public"."enum__friend_status" OWNER TO "postgres";

--
-- Name: enum__name_display; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."enum__name_display" AS ENUM (
    'full_name',
    'username'
);


ALTER TYPE "public"."enum__name_display" OWNER TO "postgres";

--
-- Name: rating; Type: DOMAIN; Schema: public; Owner: postgres
--

CREATE DOMAIN "public"."rating" AS smallint
	CONSTRAINT "rating_check" CHECK (((VALUE >= 0) AND (VALUE <= 10)));


ALTER DOMAIN "public"."rating" OWNER TO "postgres";

--
-- Name: fnc__accept_friend_request("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: check_ins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."check_ins" (
    "id" bigint NOT NULL,
    "rating" "public"."domain__rating",
    "review" "public"."domain__long_text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "product_id" bigint NOT NULL,
    "image_url" "text",
    "serving_style_id" bigint,
    "product_variant_id" bigint,
    "location_id" "uuid"
);


ALTER TABLE "public"."check_ins" OWNER TO "postgres";

--
-- Name: fnc__create_check_in(bigint, numeric, "text", bigint, bigint, "uuid"[], bigint[], "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric DEFAULT NULL::integer, "p_review" "text" DEFAULT NULL::"text", "p_manufacturer_id" bigint DEFAULT NULL::bigint, "p_serving_style_id" bigint DEFAULT NULL::bigint, "p_friend_ids" "uuid"[] DEFAULT NULL::"uuid"[], "p_flavor_ids" bigint[] DEFAULT NULL::bigint[], "p_location_id" "uuid" DEFAULT NULL::"uuid") RETURNS SETOF "public"."check_ins"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") OWNER TO "postgres";

--
-- Name: company_edit_suggestions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."company_edit_suggestions" (
    "id" bigint NOT NULL,
    "company_id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "logo_url" "text",
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."company_edit_suggestions" OWNER TO "postgres";

--
-- Name: fnc__create_company_edit_suggestion(bigint, "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."products" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "category_id" bigint NOT NULL,
    "sub_brand_id" bigint NOT NULL,
    "is_verified" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."products" OWNER TO "postgres";

--
-- Name: fnc__create_product("text", "text", bigint, bigint[], bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint DEFAULT NULL::bigint) RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint) OWNER TO "postgres";

--
-- Name: product_edit_suggestions; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: fnc__create_product_edit_suggestion(bigint, "text", "text", bigint, bigint[], bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint DEFAULT NULL::bigint) RETURNS SETOF "public"."product_edit_suggestions"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  v_product_edit_suggestion_id bigint;
  v_changed_name               text;
  v_changed_description        text;
  v_changed_category_id        bigint;
  v_changed_sub_brand_id       bigint;
  v_current_product            products%ROWTYPE;
BEGIN
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
END

$$;


ALTER FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint) OWNER TO "postgres";

--
-- Name: fnc__current_user_has_permission("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
begin
  if fnc__has_permission(auth.uid(), p_permission_name) then
    raise exception 'user has no access to this feature';
  end if;
  return true;
end ;
$$;


ALTER FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") OWNER TO "postgres";

--
-- Name: fnc__delete_current_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__delete_current_user"() RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
delete from auth.users where id = auth.uid();
$$;


ALTER FUNCTION "public"."fnc__delete_current_user"() OWNER TO "postgres";

--
-- Name: fnc__export_data(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__export_data"() RETURNS TABLE("id" "uuid", "category" "text", "subcategory" "text", "manufacturer" "text", "brand_owner" "text", "brand" "text", "sub_brand" "text", "name" "text", "reviews" "text", "ratings" "text", "username" "text")
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
                SELECT pr.id,
                       ap.category::text,
                       ap.subcategory::text,
                       m.name::text                           AS manufacturer,
                       ap.brand_owner::text,
                       ap.brand::text,
                       ap.sub_brand::text,
                       ap.name::text,
                       string_agg(c.review, ', '::text) AS reviews,
                       string_agg((((c.rating)::double precision / (2)::double precision))::text,
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

--
-- Name: fnc__get_activity_feed("date"); Type: FUNCTION; Schema: public; Owner: postgres
--

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
                                          and user_id_1 = auth.uid()
                                         or user_id_2 = auth.uid())
                  select c.*
                  from check_ins c
                  where (p_created_after is null or c.created_at > p_created_after) and (created_by = auth.uid()
                     or created_by in (select friend_id from friend_ids)))
                  order by created_at desc;
end;
$$;


ALTER FUNCTION "public"."fnc__get_activity_feed"("p_created_after" "date") OWNER TO "postgres";

--
-- Name: fnc__get_check_in_reaction_notification(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_title text;
  v_body  text;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' reacted to your check-in of ', b.name, ' ', case
                                                                                               when sb.name is not null
                                                                                                 then
                                                                                                 concat(sb.name, ' ')
                                                                                               else
                                                                                                 ''
    end, b.name, ' from ', bo.name)
  from check_in_reactions cir
         left join check_ins c on cir.check_in_id = c.id
         left join profiles p on p.id = c.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where cir.id = p_check_in_reaction_id
  into v_body;

  return jsonb_build_object('notification', jsonb_build_object('title', v_title, 'body', v_body));
end;
$$;


ALTER FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) OWNER TO "postgres";

--
-- Name: fnc__get_check_in_tag_notification(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_title text;
  v_body  text;
begin
  select '' into v_title;
  select concat(p.preferred_name, ' tagged you in a check-in of ', b.name, ' ', case
                                                                                               when sb.name is not null
                                                                                                 then
                                                                                                 concat(sb.name, ' ')
                                                                                               else
                                                                                                 ''
    end, b.name, ' from ', bo.name)
  from check_ins c
         left join profiles p on p.id = c.created_by
         left join products pr on c.product_id = pr.id
         left join sub_brands sb on sb.id = pr.sub_brand_id
         left join brands b on sb.brand_id = b.id
         left join companies bo on b.brand_owner_id = bo.id
  where c.id = p_check_in_tag
  into v_body;

  return jsonb_build_object('notification', jsonb_build_object('title', v_title, 'body', v_body));
end;
$$;


ALTER FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) OWNER TO "postgres";

--
-- Name: fnc__get_company_summary(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) RETURNS TABLE("total_check_ins" bigint, "average_rating" numeric, "current_user_average_rating" numeric)
    LANGUAGE "plpgsql"
    AS $$
begin
  return query (select count(ci.id)                                                         total_check_ins,
                       round(avg(ci.rating), 2)                                             average_rating,
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

--
-- Name: fnc__get_edge_function_authorization_header(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_edge_function_authorization_header"() RETURNS "jsonb"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
select concat('{ "Authorization": "Bearer ', supabase_anon_key, '" }')::jsonb from secrets limit 1;
$$;


ALTER FUNCTION "public"."fnc__get_edge_function_authorization_header"() OWNER TO "postgres";

--
-- Name: fnc__get_edge_function_url("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") RETURNS "text"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
select concat('https://', project_id, '.functions.supabase.co', '/', p_function_name) from secrets limit 1;
$$;


ALTER FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") OWNER TO "postgres";

--
-- Name: fnc__get_friend_request_notification(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) RETURNS "jsonb"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_title text;
  v_body  text;
begin
    select '' into v_title;
    select p.preferred_name || ' sent you a friend request!'
    from friends f
           left join profiles p on p.id = f.user_id_1
    where f.id = p_friend_id
    into v_body;

  return jsonb_build_object('notification', jsonb_build_object('title', v_title, 'body', v_body));
end;
$$;


ALTER FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) OWNER TO "postgres";

--
-- Name: fnc__get_product_summary(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) RETURNS TABLE("total_check_ins" bigint, "average_rating" numeric, "current_user_average_rating" numeric)
    LANGUAGE "plpgsql"
    AS $$
begin
  return query (select count(ci.id)                                                        total_check_ins,
                       round(avg(ci.rating), 2)                                            average_rating,
                       round(avg(ci.rating) filter ( where ci.created_by = auth.uid() ), 2) current_user_average_rating
                from products p
                  left join check_ins ci on p.id = ci.product_id
                where p.id = p_product_id);
end ;
$$;


ALTER FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) OWNER TO "postgres";

--
-- Name: fnc__get_profile_summary("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: fnc__get_push_notification_request("uuid", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_id" "uuid", "p_notification" "jsonb") RETURNS TABLE("url" "text", "headers" "jsonb", "body" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  v_url                   text;
  v_headers               jsonb;
  v_receiver_device_token text;
  v_body                  jsonb;
begin
  select concat('https://fcm.googleapis.com/v1/projects/', firebase_project_id, '/messages:send')
  from secrets v_url
  into v_url;

  select concat('{ "Content-Type": "application/json", "Authorization": "Bearer ', firebase_access_token, '" }')::jsonb
  from secrets
  into v_headers;

  select firebase_registration_token
  from profile_push_notification_tokens
  where created_by = p_receiver_id
  into v_receiver_device_token;

  select jsonb_build_object('message',
                            jsonb_build_object('token', v_receiver_device_token) || p_notification)
  into
    v_body;

  return query (select v_url url, v_headers headers, v_body body);
end
$$;


ALTER FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_id" "uuid", "p_notification" "jsonb") OWNER TO "postgres";

--
-- Name: fnc__has_permission("uuid", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: fnc__merge_products(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) RETURNS SETOF "public"."products"
    LANGUAGE "plpgsql"
    AS $$
begin
  if fnc__current_user_has_permission('can_merge_products') then
    update check_ins set product_id = p_to_product_id where id = p_product_id;
    -- some objects are lost, such as edit suggestions
    delete from products where id = p_product_id;
  end if;
end ;
$$;


ALTER FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) OWNER TO "postgres";

--
-- Name: fnc__post_request("text", "jsonb", "jsonb"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: fnc__refresh_firebase_access_token(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__refresh_firebase_access_token"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
declare
  v_url text;
  v_headers jsonb;
begin
  select fnc__get_edge_function_url('get-fcm-access-token') into v_url;
  select fnc__get_edge_function_authorization_header() into v_headers;
  perform net.http_get(v_url, headers := v_headers);
  end;
$$;


ALTER FUNCTION "public"."fnc__refresh_firebase_access_token"() OWNER TO "postgres";

--
-- Name: fnc__search_products("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__search_products"("p_search_term" "text") RETURNS SETOF "public"."products"
    LANGUAGE "sql"
    AS $$
select p.*
from products p
         left join "sub_brands" sb on sb.id = p."sub_brand_id"
         left join brands b on sb.brand_id = b.id
         left join companies c on b.brand_owner_id = c.id
WHERE p.name ilike p_search_term
   or p.description ilike p_search_term
   or sb.name ilike p_search_term
   or b.name ilike p_search_term
   or c.name ilike p_search_term;
$$;


ALTER FUNCTION "public"."fnc__search_products"("p_search_term" "text") OWNER TO "postgres";

--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."profiles" (
    "id" "uuid" NOT NULL,
    "first_name" "public"."domain__name",
    "last_name" "public"."domain__name",
    "username" "public"."domain__name" NOT NULL,
    "avatar_url" "text",
    "name_display" "public"."enum__name_display" DEFAULT 'username'::"public"."enum__name_display",
    "search" "text" GENERATED ALWAYS AS (((("username")::"text" || COALESCE(("first_name")::"text", ''::"text")) || COALESCE(("last_name")::"text", ''::"text"))) STORED,
    "preferred_name" "text" GENERATED ALWAYS AS (
CASE
    WHEN ("name_display" = 'full_name'::"public"."enum__name_display") THEN ((("first_name")::"text" || ' '::"text") || ("last_name")::"text")
    ELSE ("username")::"text"
END) STORED
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";

--
-- Name: fnc__search_profiles("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: fnc__update_check_in(bigint, bigint, integer, "text", bigint, bigint, "uuid"[], bigint[], "uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" integer DEFAULT NULL::integer, "p_review" "text" DEFAULT NULL::"text", "p_manufacturer_id" bigint DEFAULT NULL::bigint, "p_serving_style_id" bigint DEFAULT NULL::bigint, "p_friend_ids" "uuid"[] DEFAULT NULL::"uuid"[], "p_flavor_ids" bigint[] DEFAULT NULL::bigint[], "p_location_id" "uuid" DEFAULT NULL::"uuid") RETURNS SETOF "public"."check_ins"
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
$$;


ALTER FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" integer, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") OWNER TO "postgres";

--
-- Name: fnc__upsert_push_notification_token("text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
insert into profile_push_notification_tokens (firebase_registration_token, created_by)
values (p_push_notification_token, auth.uid())
on conflict (firebase_registration_token)
  do update set updated_at = now(), created_by = auth.uid();
$$;


ALTER FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") OWNER TO "postgres";

--
-- Name: tg__check_friend_status_transition(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__check_subcategory_constraint(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__clean_up_check_in(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

  select trim(v_trimmed_review) into v_trimmed_review;

  if new.review is null or length(v_trimmed_review) = 0 then
    new.review = null;
  else
    new.review = v_trimmed_review;
  end if;

  return new;
end;
$$;


ALTER FUNCTION "public"."tg__clean_up_check_in"() OWNER TO "postgres";

--
-- Name: tg__create_default_sub_brand(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__create_default_sub_brand"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  insert into sub_brands (name, brand_id, created_by)
  values (null, new.id, auth.uid());
  return new;
end;
$$;


ALTER FUNCTION "public"."tg__create_default_sub_brand"() OWNER TO "postgres";

--
-- Name: tg__create_friend_request(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__create_profile_for_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__create_profile_for_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
    v_username text;
begin
    select split_part(email, '@', 1)
    into v_username
    from auth.users
    where id = new.id;

    insert
    into public.profiles (id, username)
    values (new.id, v_username);
    return new;
end;
$$;


ALTER FUNCTION "public"."tg__create_profile_for_new_user"() OWNER TO "postgres";

--
-- Name: tg__create_profile_settings(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__forbid_changing_check_in_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__forbid_changing_check_in_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
begin
  new.check_in_id = old.check_in_id;
end;
$$;


ALTER FUNCTION "public"."tg__forbid_changing_check_in_id"() OWNER TO "postgres";

--
-- Name: tg__forbid_send_messages_too_often(); Type: FUNCTION; Schema: public; Owner: postgres
--

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
  else
    return new;
  end if;
end;
$$;


ALTER FUNCTION "public"."tg__forbid_send_messages_too_often"() OWNER TO "postgres";

--
-- Name: tg__friend_request_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__is_verified_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__make_id_immutable(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__make_id_immutable"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
  NEW.id := OLD.id;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."tg__make_id_immutable"() OWNER TO "postgres";

--
-- Name: tg__must_be_friends(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__refresh_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__remove_unused_tokens(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__remove_unused_tokens"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  delete from profile_push_notification_tokens where updated_at < now() - interval '1 month';
  return new;
end;
$$;


ALTER FUNCTION "public"."tg__remove_unused_tokens"() OWNER TO "postgres";

--
-- Name: tg__send_check_in_reaction_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__send_friend_request_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__send_push_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__send_push_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
declare
  v_notification jsonb;
begin
  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
  elseif new.tagged_in_check_in_id is not null then
   select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
  end if;

  perform fnc__post_request(url, headers, body)
  from fnc__get_push_notification_request(new.profile_id, v_notification);
  
  return new;
end;
$$;


ALTER FUNCTION "public"."tg__send_push_notification"() OWNER TO "postgres";

--
-- Name: tg__send_tagged_in_check_in_notification(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__send_tagged_in_check_in_notification"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
declare
  v_send_notification bool;
begin
  select send_tagged_check_in_notifications into v_send_notification from profile_settings where id = new.profile_id;
  
  if v_send_notification then
      insert into notifications (profile_id, tagged_in_check_in_id) values (new.profile_id, new.check_in_id);
  end if;
  
  return new;
end;
$$;


ALTER FUNCTION "public"."tg__send_tagged_in_check_in_notification"() OWNER TO "postgres";

--
-- Name: tg__set_avatar_on_upload(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."tg__set_avatar_on_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
  if new.bucket_id = 'avatars' then
    delete from storage.objects where name = new.name;
    update public.profiles set avatar_url = new.name where id = auth.uid();
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."tg__set_avatar_on_upload"() OWNER TO "postgres";

--
-- Name: tg__set_check_in_image_on_upload(); Type: FUNCTION; Schema: public; Owner: postgres
--

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
    set image_url = fp.image_url
    from formatted_parts fp
    where created_by = new.owner
      and id = fp.check_in_id;
  end if;
  return new;
end;
$$;


ALTER FUNCTION "public"."tg__set_check_in_image_on_upload"() OWNER TO "postgres";

--
-- Name: tg__stamp_created_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__stamp_created_by(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__stamp_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__trim_description_empty_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: tg__trim_name_empty_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

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

--
-- Name: brand_edit_suggestions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."brand_edit_suggestions" (
    "id" bigint NOT NULL,
    "brand_id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "brand_owner_id" bigint,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."brand_edit_suggestions" OWNER TO "postgres";

--
-- Name: brand_edit_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."brand_edit_suggestions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."brand_edit_suggestions_id_seq" OWNER TO "postgres";

--
-- Name: brand_edit_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."brand_edit_suggestions_id_seq" OWNED BY "public"."brand_edit_suggestions"."id";


--
-- Name: brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."brands" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "brand_owner_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "is_verified" boolean DEFAULT false NOT NULL,
    "logo_url" "text"
);


ALTER TABLE "public"."brands" OWNER TO "postgres";

--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."brands" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."brands_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."categories" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL
);


ALTER TABLE "public"."categories" OWNER TO "postgres";

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."categories" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."categories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: category_serving_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."category_serving_styles" (
    "category_id" bigint NOT NULL,
    "serving_style_id" bigint NOT NULL
);


ALTER TABLE "public"."category_serving_styles" OWNER TO "postgres";

--
-- Name: check_in_comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."check_in_comments" (
    "id" bigint NOT NULL,
    "content" "public"."domain__long_text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "check_in_id" integer NOT NULL
);


ALTER TABLE "public"."check_in_comments" OWNER TO "postgres";

--
-- Name: check_in_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_in_comments" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."check_in_comments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: check_in_flavors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."check_in_flavors" (
    "check_in_id" bigint,
    "flavor_id" bigint
);


ALTER TABLE "public"."check_in_flavors" OWNER TO "postgres";

--
-- Name: check_in_reactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."check_in_reactions" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid" NOT NULL,
    "check_in_id" bigint NOT NULL
);


ALTER TABLE "public"."check_in_reactions" OWNER TO "postgres";

--
-- Name: check_in_reactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_in_reactions" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."check_in_reactions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: check_in_tagged_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."check_in_tagged_profiles" (
    "check_in_id" bigint NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."check_in_tagged_profiles" OWNER TO "postgres";

--
-- Name: check_ins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_ins" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."check_ins_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."companies" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "logo_url" "text",
    "is_verified" boolean DEFAULT false,
    "subsidiary_of" bigint,
    "description" "text"
);


ALTER TABLE "public"."companies" OWNER TO "postgres";

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."companies" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."companies_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: company_edit_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."company_edit_suggestions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."company_edit_suggestions_id_seq" OWNER TO "postgres";

--
-- Name: company_edit_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."company_edit_suggestions_id_seq" OWNED BY "public"."company_edit_suggestions"."id";


--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."countries" (
    "country_code" character(2) NOT NULL,
    "name" "text" NOT NULL,
    "emoji" "text" NOT NULL
);


ALTER TABLE "public"."countries" OWNER TO "postgres";

--
-- Name: flavors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."flavors" (
    "id" bigint NOT NULL,
    "name" "text"
);


ALTER TABLE "public"."flavors" OWNER TO "postgres";

--
-- Name: flavors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."flavors" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."flavors_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: friends; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: friends_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."friends" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."friends_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."notifications" (
    "id" bigint NOT NULL,
    "message" "text",
    "profile_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "friend_request_id" bigint,
    "tagged_in_check_in_id" bigint,
    "check_in_reaction_id" bigint
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."notifications_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."notifications_id_seq" OWNER TO "postgres";

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."notifications_id_seq" OWNED BY "public"."notifications"."id";


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."permissions" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL
);


ALTER TABLE "public"."permissions" OWNER TO "postgres";

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."permissions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."permissions_id_seq" OWNER TO "postgres";

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."permissions_id_seq" OWNED BY "public"."permissions"."id";


--
-- Name: product_edit_suggestion_subcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."product_edit_suggestion_subcategories" (
    "id" bigint NOT NULL,
    "product_edit_suggestion_id" bigint NOT NULL,
    "subcategory_id" bigint NOT NULL,
    "delete" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."product_edit_suggestion_subcategories" OWNER TO "postgres";

--
-- Name: product_edit_suggestion_subcategories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."product_edit_suggestion_subcategories_id_seq" OWNER TO "postgres";

--
-- Name: product_edit_suggestion_subcategories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" OWNED BY "public"."product_edit_suggestion_subcategories"."id";


--
-- Name: product_edit_suggestions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."product_edit_suggestions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."product_edit_suggestions_id_seq" OWNER TO "postgres";

--
-- Name: product_edit_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."product_edit_suggestions_id_seq" OWNED BY "public"."product_edit_suggestions"."id";


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."product_variants" (
    "id" bigint NOT NULL,
    "product_id" bigint NOT NULL,
    "manufacturer_id" bigint,
    "created_by" "uuid",
    "is_verified" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."product_variants" OWNER TO "postgres";

--
-- Name: product_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."product_variants_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."product_variants_id_seq" OWNER TO "postgres";

--
-- Name: product_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."product_variants_id_seq" OWNED BY "public"."product_variants"."id";


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."products_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: products_subcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."products_subcategories" (
    "product_id" bigint NOT NULL,
    "subcategory_id" bigint NOT NULL,
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "is_verified" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."products_subcategories" OWNER TO "postgres";

--
-- Name: products_subcategories_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products_subcategories" ALTER COLUMN "product_id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."products_subcategories_product_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: profile_push_notification_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."profile_push_notification_tokens" (
    "firebase_registration_token" "text" NOT NULL,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."profile_push_notification_tokens" OWNER TO "postgres";

--
-- Name: profile_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."profile_settings" (
    "id" "uuid" NOT NULL,
    "color_scheme" "public"."enum__color_scheme" DEFAULT 'system'::"public"."enum__color_scheme" NOT NULL,
    "send_reaction_notifications" boolean DEFAULT true NOT NULL,
    "send_tagged_check_in_notifications" boolean DEFAULT true NOT NULL,
    "send_friend_request_notifications" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."profile_settings" OWNER TO "postgres";

--
-- Name: profiles_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."profiles_roles" (
    "profile_id" "uuid" NOT NULL,
    "role_id" bigint NOT NULL
);


ALTER TABLE "public"."profiles_roles" OWNER TO "postgres";

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."roles" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."roles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."roles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: roles_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."roles_permissions" (
    "role_id" bigint NOT NULL,
    "permission_id" bigint NOT NULL
);


ALTER TABLE "public"."roles_permissions" OWNER TO "postgres";

--
-- Name: secrets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."secrets" (
    "firebase_access_token" "text",
    "supabase_anon_key" "text" NOT NULL,
    "project_id" "text" NOT NULL,
    "firebase_project_id" "text"
);


ALTER TABLE "public"."secrets" OWNER TO "postgres";

--
-- Name: serving_styles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."serving_styles" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL
);


ALTER TABLE "public"."serving_styles" OWNER TO "postgres";

--
-- Name: serving_styles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."serving_styles" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."serving_styles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: sub_brand_edit_suggestion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."sub_brand_edit_suggestion" (
    "id" bigint NOT NULL,
    "sub_brand_id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "brand_id" bigint,
    "created_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."sub_brand_edit_suggestion" OWNER TO "postgres";

--
-- Name: sub_brand_edit_suggestion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "public"."sub_brand_edit_suggestion_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "public"."sub_brand_edit_suggestion_id_seq" OWNER TO "postgres";

--
-- Name: sub_brand_edit_suggestion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" OWNED BY "public"."sub_brand_edit_suggestion"."id";


--
-- Name: sub_brands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."sub_brands" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text",
    "brand_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "is_verified" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."sub_brands" OWNER TO "postgres";

--
-- Name: sub_brands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."sub_brands" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."sub_brands_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: subcategories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."subcategories" (
    "id" bigint NOT NULL,
    "name" "public"."domain__short_text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    "category_id" bigint NOT NULL,
    "is_verified" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."subcategories" OWNER TO "postgres";

--
-- Name: subcategories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."subcategories" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."subcategories_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1
);


--
-- Name: brand_edit_suggestions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brand_edit_suggestions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."brand_edit_suggestions_id_seq"'::"regclass");


--
-- Name: company_edit_suggestions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."company_edit_suggestions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."company_edit_suggestions_id_seq"'::"regclass");


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notifications" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."notifications_id_seq"'::"regclass");


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."permissions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."permissions_id_seq"'::"regclass");


--
-- Name: product_edit_suggestion_subcategories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_edit_suggestion_subcategories_id_seq"'::"regclass");


--
-- Name: product_edit_suggestions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestions" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_edit_suggestions_id_seq"'::"regclass");


--
-- Name: product_variants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."product_variants_id_seq"'::"regclass");


--
-- Name: sub_brand_edit_suggestion id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."sub_brand_edit_suggestion_id_seq"'::"regclass");


--
-- Name: brand_edit_suggestions brand_edit_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brand_edit_suggestions"
    ADD CONSTRAINT "brand_edit_suggestions_pkey" PRIMARY KEY ("id");


--
-- Name: brands brand_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brand_pkey" PRIMARY KEY ("id");


--
-- Name: brands brands_brand_owner_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_brand_owner_id_name_key" UNIQUE ("brand_owner_id", "name");


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_name_key" UNIQUE ("name");


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");


--
-- Name: category_serving_styles category_serving_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."category_serving_styles"
    ADD CONSTRAINT "category_serving_styles_pkey" PRIMARY KEY ("category_id", "serving_style_id");


--
-- Name: check_in_comments check_in_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_comments"
    ADD CONSTRAINT "check_in_comments_pkey" PRIMARY KEY ("id");


--
-- Name: check_in_flavors check_in_flavors_check_in_id_flavor_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_flavors"
    ADD CONSTRAINT "check_in_flavors_check_in_id_flavor_id_key" UNIQUE ("check_in_id", "flavor_id");


--
-- Name: check_in_reactions check_in_reactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "check_in_reactions_pkey" PRIMARY KEY ("id");


--
-- Name: check_in_tagged_profiles check_in_tagged_profiles_check_in_id_profile_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_tagged_profiles"
    ADD CONSTRAINT "check_in_tagged_profiles_check_in_id_profile_id_key" UNIQUE ("check_in_id", "profile_id");


--
-- Name: check_ins check_ins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_pkey" PRIMARY KEY ("id");


--
-- Name: companies companies_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_name_key" UNIQUE ("name");


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_pkey" PRIMARY KEY ("id");


--
-- Name: company_edit_suggestions company_edit_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."company_edit_suggestions"
    ADD CONSTRAINT "company_edit_suggestions_pkey" PRIMARY KEY ("id");


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."countries"
    ADD CONSTRAINT "countries_pkey" PRIMARY KEY ("country_code");


--
-- Name: flavors flavors_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."flavors"
    ADD CONSTRAINT "flavors_name_key" UNIQUE ("name");


--
-- Name: flavors flavors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."flavors"
    ADD CONSTRAINT "flavors_pkey" PRIMARY KEY ("id");


--
-- Name: friends friends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_pkey" PRIMARY KEY ("id");


--
-- Name: friends friends_user_id_1_user_id_2_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_user_id_1_user_id_2_key" UNIQUE ("user_id_1", "user_id_2");


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_pkey" PRIMARY KEY ("id");


--
-- Name: notifications notifications_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pk" PRIMARY KEY ("id");


--
-- Name: check_in_reactions one_reaction_per_user; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "one_reaction_per_user" UNIQUE ("check_in_id", "created_by");


--
-- Name: product_edit_suggestion_subcategories product_edit_suggestion_subcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories"
    ADD CONSTRAINT "product_edit_suggestion_subcategories_pkey" PRIMARY KEY ("id");


--
-- Name: product_edit_suggestions product_edit_suggestions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_pkey" PRIMARY KEY ("id");


--
-- Name: products product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "product_pkey" PRIMARY KEY ("id");


--
-- Name: product_variants product_variants_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_pk" PRIMARY KEY ("id");


--
-- Name: product_variants product_variants_product_id_manufacturer_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_manufacturer_id_key" UNIQUE ("product_id", "manufacturer_id");


--
-- Name: products_subcategories products_subcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_pkey" PRIMARY KEY ("product_id", "subcategory_id");


--
-- Name: profile_push_notification_tokens profile_push_notification_token_firebase_registration_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profile_push_notification_tokens"
    ADD CONSTRAINT "profile_push_notification_token_firebase_registration_token_key" UNIQUE ("firebase_registration_token");


--
-- Name: profile_push_notification_tokens profile_push_notification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profile_push_notification_tokens"
    ADD CONSTRAINT "profile_push_notification_tokens_pkey" PRIMARY KEY ("firebase_registration_token");


--
-- Name: profile_settings profile_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profile_settings"
    ADD CONSTRAINT "profile_settings_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");


--
-- Name: profiles_roles profiles_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles_roles"
    ADD CONSTRAINT "profiles_roles_pkey" PRIMARY KEY ("profile_id", "role_id");


--
-- Name: profiles profiles_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");


--
-- Name: permissions role_permission_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."permissions"
    ADD CONSTRAINT "role_permission_pk" PRIMARY KEY ("id");


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_name_key" UNIQUE ("name");


--
-- Name: roles_permissions roles_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles_permissions"
    ADD CONSTRAINT "roles_permissions_pkey" PRIMARY KEY ("role_id", "permission_id");


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");


--
-- Name: secrets secrets_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."secrets"
    ADD CONSTRAINT "secrets_pk" PRIMARY KEY ("supabase_anon_key");


--
-- Name: serving_styles serving_styles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."serving_styles"
    ADD CONSTRAINT "serving_styles_pkey" PRIMARY KEY ("id");


--
-- Name: sub_brand_edit_suggestion sub_brand_edit_suggestion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_pkey" PRIMARY KEY ("id");


--
-- Name: sub_brands sub_brand_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brand_pkey" PRIMARY KEY ("id");


--
-- Name: sub_brands sub_brands_brand_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brands_brand_id_name_key" UNIQUE ("brand_id", "name");


--
-- Name: subcategories subcategories_category_id_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_category_id_name_key" UNIQUE ("category_id", "name");


--
-- Name: subcategories subcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_pkey" PRIMARY KEY ("id");


--
-- Name: products_subcategories unique_product_subcategory; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "unique_product_subcategory" UNIQUE ("product_id", "subcategory_id");


--
-- Name: brand_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "brand_name_idx" ON "public"."products" USING "gist" (COALESCE(("name")::"text", "description") "public"."gist_trgm_ops");


--
-- Name: check_ins_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "check_ins_created_at_idx" ON "public"."check_ins" USING "btree" ("created_at");


--
-- Name: product_description_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "product_description_idx" ON "public"."products" USING "gist" ("description" "public"."gist_trgm_ops");


--
-- Name: product_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "product_name_idx" ON "public"."products" USING "gist" ("name" "public"."gist_trgm_ops");


--
-- Name: sub_brand_name_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "sub_brand_name_idx" ON "public"."sub_brands" USING "gist" ("name" "public"."gist_trgm_ops");


--
-- Name: profiles add_options_for_profile; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "add_options_for_profile" AFTER INSERT ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__create_profile_settings"();


--
-- Name: friends check_if_insert_or_update_is_allowed; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_if_insert_or_update_is_allowed" BEFORE INSERT OR UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__friend_request_check"();


--
-- Name: products_subcategories check_subcategory_constraint; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_subcategory_constraint" BEFORE INSERT OR UPDATE ON "public"."products_subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__check_subcategory_constraint"();


--
-- Name: brands check_verification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();


--
-- Name: companies check_verification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();


--
-- Name: product_variants check_verification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."product_variants" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();


--
-- Name: products check_verification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();


--
-- Name: products_subcategories check_verification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."products_subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();


--
-- Name: sub_brands check_verification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();


--
-- Name: subcategories check_verification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "check_verification" BEFORE INSERT OR UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__is_verified_check"();


--
-- Name: check_ins clean_up; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "clean_up" BEFORE INSERT OR UPDATE ON "public"."check_ins" FOR EACH ROW EXECUTE FUNCTION "public"."tg__clean_up_check_in"();


--
-- Name: brands create_default_sub_brand; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "create_default_sub_brand" AFTER INSERT ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__create_default_sub_brand"();


--
-- Name: profile_push_notification_tokens delete_unused_tokens; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "delete_unused_tokens" AFTER INSERT ON "public"."profile_push_notification_tokens" FOR EACH STATEMENT EXECUTE FUNCTION "public"."tg__remove_unused_tokens"();


--
-- Name: check_in_comments forbid_send_messages_too_often; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "forbid_send_messages_too_often" BEFORE INSERT ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__forbid_send_messages_too_often"();


--
-- Name: check_in_tagged_profiles forbid_tagging_users_that_are_not_friends; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "forbid_tagging_users_that_are_not_friends" BEFORE INSERT ON "public"."check_in_tagged_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__must_be_friends"();


--
-- Name: check_in_comments make_check_in_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_check_in_id_immutable" BEFORE UPDATE ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__forbid_changing_check_in_id"();


--
-- Name: check_in_comments make_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();


--
-- Name: check_ins make_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."check_ins" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();


--
-- Name: friends make_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();


--
-- Name: profile_settings make_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."profile_settings" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();


--
-- Name: profiles make_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();


--
-- Name: sub_brands make_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();


--
-- Name: subcategories make_id_immutable; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "make_id_immutable" BEFORE UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__make_id_immutable"();


--
-- Name: friends on_friend_request_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "on_friend_request_update" BEFORE INSERT OR UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__check_friend_status_transition"();


--
-- Name: check_in_tagged_profiles send_notification_on_being_tagged_on_check_in; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "send_notification_on_being_tagged_on_check_in" AFTER INSERT ON "public"."check_in_tagged_profiles" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_tagged_in_check_in_notification"();


--
-- Name: check_in_reactions send_notification_on_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "send_notification_on_insert" AFTER INSERT ON "public"."check_in_reactions" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_check_in_reaction_notification"();


--
-- Name: friends send_notification_on_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "send_notification_on_insert" AFTER INSERT ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_friend_request_notification"();


--
-- Name: notifications send_push_notification; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "send_push_notification" AFTER INSERT ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "public"."tg__send_push_notification"();


--
-- Name: friends stamp_created_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_at" BEFORE INSERT OR UPDATE ON "public"."friends" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_at"();


--
-- Name: brands stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: check_in_comments stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."check_in_comments" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: check_in_reactions stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."check_in_reactions" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: check_ins stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."check_ins" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: companies stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: locations stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."locations" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: product_variants stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."product_variants" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: products stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: products_subcategories stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."products_subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: profile_push_notification_tokens stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."profile_push_notification_tokens" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: sub_brands stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: subcategories stamp_created_by; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_created_by" BEFORE INSERT OR UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_created_by"();


--
-- Name: profile_push_notification_tokens stamp_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "stamp_updated_at" BEFORE INSERT OR UPDATE ON "public"."profile_push_notification_tokens" FOR EACH ROW EXECUTE FUNCTION "public"."tg__stamp_updated_at"();


--
-- Name: products trim_description_empty_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trim_description_empty_check" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_description_empty_check"();


--
-- Name: brands trim_name_empty_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();


--
-- Name: companies trim_name_empty_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."companies" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();


--
-- Name: products trim_name_empty_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."products" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();


--
-- Name: sub_brands trim_name_empty_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."sub_brands" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();


--
-- Name: subcategories trim_name_empty_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "trim_name_empty_check" BEFORE INSERT OR UPDATE ON "public"."subcategories" FOR EACH ROW EXECUTE FUNCTION "public"."tg__trim_name_empty_check"();


--
-- Name: brand_edit_suggestions brand_edit_suggestions_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brand_edit_suggestions"
    ADD CONSTRAINT "brand_edit_suggestions_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE CASCADE;


--
-- Name: brand_edit_suggestions brand_edit_suggestions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brand_edit_suggestions"
    ADD CONSTRAINT "brand_edit_suggestions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: brands brands_brand_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_brand_owner_id_fkey" FOREIGN KEY ("brand_owner_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;


--
-- Name: brands brands_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."brands"
    ADD CONSTRAINT "brands_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: category_serving_styles category_serving_styles_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."category_serving_styles"
    ADD CONSTRAINT "category_serving_styles_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;


--
-- Name: category_serving_styles category_serving_styles_serving_style_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."category_serving_styles"
    ADD CONSTRAINT "category_serving_styles_serving_style_id_fkey" FOREIGN KEY ("serving_style_id") REFERENCES "public"."serving_styles"("id") ON DELETE CASCADE;


--
-- Name: check_in_comments check_in_comments_check_in_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_comments"
    ADD CONSTRAINT "check_in_comments_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;


--
-- Name: check_in_comments check_in_comments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_comments"
    ADD CONSTRAINT "check_in_comments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: check_in_flavors check_in_flavors_check_in_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_flavors"
    ADD CONSTRAINT "check_in_flavors_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;


--
-- Name: check_in_flavors check_in_flavors_flavor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_flavors"
    ADD CONSTRAINT "check_in_flavors_flavor_id_fkey" FOREIGN KEY ("flavor_id") REFERENCES "public"."flavors"("id") ON DELETE CASCADE;


--
-- Name: check_in_reactions check_in_reactions_check_in_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "check_in_reactions_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;


--
-- Name: check_in_reactions check_in_reactions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_reactions"
    ADD CONSTRAINT "check_in_reactions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: check_in_tagged_profiles check_in_tagged_profiles_check_in_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_tagged_profiles"
    ADD CONSTRAINT "check_in_tagged_profiles_check_in_id_fkey" FOREIGN KEY ("check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;


--
-- Name: check_in_tagged_profiles check_in_tagged_profiles_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_in_tagged_profiles"
    ADD CONSTRAINT "check_in_tagged_profiles_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: check_ins check_ins_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: check_ins check_ins_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."locations"("id") ON DELETE SET NULL;


--
-- Name: check_ins check_ins_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: check_ins check_ins_product_variant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_product_variant_id_fkey" FOREIGN KEY ("product_variant_id") REFERENCES "public"."product_variants"("id") ON DELETE SET NULL;


--
-- Name: check_ins check_ins_serving_style_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."check_ins"
    ADD CONSTRAINT "check_ins_serving_style_id_fkey" FOREIGN KEY ("serving_style_id") REFERENCES "public"."serving_styles"("id") ON DELETE SET NULL;


--
-- Name: companies companies_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: companies companies_subsidiary_of_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_subsidiary_of_fkey" FOREIGN KEY ("subsidiary_of") REFERENCES "public"."companies"("id") ON DELETE SET NULL;


--
-- Name: company_edit_suggestions company_edit_suggestions_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."company_edit_suggestions"
    ADD CONSTRAINT "company_edit_suggestions_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;


--
-- Name: company_edit_suggestions company_edit_suggestions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."company_edit_suggestions"
    ADD CONSTRAINT "company_edit_suggestions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: friends friends_blocked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_blocked_by_fkey" FOREIGN KEY ("blocked_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: friends friends_user_id_1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_user_id_1_fkey" FOREIGN KEY ("user_id_1") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: friends friends_user_id_2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."friends"
    ADD CONSTRAINT "friends_user_id_2_fkey" FOREIGN KEY ("user_id_2") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: locations locations_countries_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_countries_fk" FOREIGN KEY ("country_code") REFERENCES "public"."countries"("country_code") ON DELETE CASCADE;


--
-- Name: locations locations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: notifications notifications_check_in_reaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_check_in_reaction_id_fkey" FOREIGN KEY ("check_in_reaction_id") REFERENCES "public"."check_in_reactions"("id") ON DELETE CASCADE;


--
-- Name: notifications notifications_friend_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_friend_request_id_fkey" FOREIGN KEY ("friend_request_id") REFERENCES "public"."friends"("id") ON DELETE CASCADE;


--
-- Name: notifications notifications_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: notifications notifications_tagged_in_check_in_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_tagged_in_check_in_id_fkey" FOREIGN KEY ("tagged_in_check_in_id") REFERENCES "public"."check_ins"("id") ON DELETE CASCADE;


--
-- Name: product_edit_suggestion_subcategories product_edit_suggestion_subcate_product_edit_suggestion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories"
    ADD CONSTRAINT "product_edit_suggestion_subcate_product_edit_suggestion_id_fkey" FOREIGN KEY ("product_edit_suggestion_id") REFERENCES "public"."product_edit_suggestions"("id") ON DELETE CASCADE;


--
-- Name: product_edit_suggestion_subcategories product_edit_suggestion_subcategories_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestion_subcategories"
    ADD CONSTRAINT "product_edit_suggestion_subcategories_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategories"("id") ON DELETE CASCADE;


--
-- Name: product_edit_suggestions product_edit_suggestions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;


--
-- Name: product_edit_suggestions product_edit_suggestions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: product_edit_suggestions product_edit_suggestions_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: product_edit_suggestions product_edit_suggestions_sub_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_edit_suggestions"
    ADD CONSTRAINT "product_edit_suggestions_sub_brand_id_fkey" FOREIGN KEY ("sub_brand_id") REFERENCES "public"."sub_brands"("id") ON DELETE CASCADE;


--
-- Name: product_variants product_variants_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: product_variants product_variants_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_manufacturer_id_fkey" FOREIGN KEY ("manufacturer_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;


--
-- Name: product_variants product_variants_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."product_variants"
    ADD CONSTRAINT "product_variants_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;


--
-- Name: products products_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: products products_sub_brands__fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_sub_brands__fk" FOREIGN KEY ("sub_brand_id") REFERENCES "public"."sub_brands"("id") ON DELETE CASCADE;


--
-- Name: products_subcategories products_subcategories_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: products_subcategories products_subcategories_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;


--
-- Name: products_subcategories products_subcategories_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."products_subcategories"
    ADD CONSTRAINT "products_subcategories_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategories"("id") ON DELETE CASCADE;


--
-- Name: profile_push_notification_tokens profile_push_notification_tokens_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profile_push_notification_tokens"
    ADD CONSTRAINT "profile_push_notification_tokens_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: profile_settings profile_settings_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profile_settings"
    ADD CONSTRAINT "profile_settings_id_fkey" FOREIGN KEY ("id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: profiles_roles profiles_roles_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles_roles"
    ADD CONSTRAINT "profiles_roles_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: profiles_roles profiles_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles_roles"
    ADD CONSTRAINT "profiles_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;


--
-- Name: roles_permissions roles_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles_permissions"
    ADD CONSTRAINT "roles_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "public"."permissions"("id") ON DELETE CASCADE;


--
-- Name: roles_permissions roles_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."roles_permissions"
    ADD CONSTRAINT "roles_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;


--
-- Name: sub_brand_edit_suggestion sub_brand_edit_suggestion_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE CASCADE;


--
-- Name: sub_brand_edit_suggestion sub_brand_edit_suggestion_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: sub_brand_edit_suggestion sub_brand_edit_suggestion_sub_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brand_edit_suggestion"
    ADD CONSTRAINT "sub_brand_edit_suggestion_sub_brand_id_fkey" FOREIGN KEY ("sub_brand_id") REFERENCES "public"."sub_brands"("id") ON DELETE CASCADE;


--
-- Name: sub_brands sub_brands_brand_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brands_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brands"("id") ON DELETE CASCADE;


--
-- Name: sub_brands sub_brands_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."sub_brands"
    ADD CONSTRAINT "sub_brands_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: subcategories subcategories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id");


--
-- Name: subcategories subcategories_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."subcategories"
    ADD CONSTRAINT "subcategories_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;


--
-- Name: job cron_job_policy; Type: POLICY; Schema: cron; Owner: supabase_admin
--

-- CREATE POLICY "cron_job_policy" ON "cron"."job" USING (("username" = CURRENT_USER));


--
-- Name: job_run_details cron_job_run_details_policy; Type: POLICY; Schema: cron; Owner: supabase_admin
--

-- CREATE POLICY "cron_job_run_details_policy" ON "cron"."job_run_details" USING (("username" = CURRENT_USER));


--
-- Name: job; Type: ROW SECURITY; Schema: cron; Owner: supabase_admin
--

ALTER TABLE "cron"."job" ENABLE ROW LEVEL SECURITY;

--
-- Name: job_run_details; Type: ROW SECURITY; Schema: cron; Owner: supabase_admin
--

ALTER TABLE "cron"."job_run_details" ENABLE ROW LEVEL SECURITY;

--
-- Name: brand_edit_suggestions Allow deleting for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow deleting for users with permission" ON "public"."brand_edit_suggestions" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));


--
-- Name: company_edit_suggestions Allow deleting for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow deleting for users with permission" ON "public"."company_edit_suggestions" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));


--
-- Name: product_edit_suggestion_subcategories Allow deleting for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow deleting for users with permission" ON "public"."product_edit_suggestion_subcategories" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));


--
-- Name: product_edit_suggestions Allow deleting for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow deleting for users with permission" ON "public"."product_edit_suggestions" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));


--
-- Name: sub_brand_edit_suggestion Allow deleting for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Allow deleting for users with permission" ON "public"."sub_brand_edit_suggestion" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_suggestions'::"text"));


--
-- Name: categories Categories are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Categories are viewable by everyone." ON "public"."categories" FOR SELECT USING (true);


--
-- Name: check_in_comments Check in comments are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Check in comments are viewable by everyone." ON "public"."check_in_comments" FOR SELECT USING (true);


--
-- Name: check_in_reactions Check in reactions are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Check in reactions are viewable by everyone." ON "public"."check_in_reactions" FOR SELECT USING (true);


--
-- Name: check_ins Check-ins are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Check-ins are viewable by everyone." ON "public"."check_ins" FOR SELECT USING (true);


--
-- Name: companies Companies are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Companies are viewable by everyone." ON "public"."companies" FOR SELECT USING (true);


--
-- Name: friends Enable delete for both sides of friend status; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for both sides of friend status" ON "public"."friends" FOR DELETE TO "authenticated" USING (((("user_id_1" = "auth"."uid"()) OR ("user_id_2" = "auth"."uid"())) AND (("status" <> 'blocked'::"public"."enum__friend_status") OR ("blocked_by" = "auth"."uid"()))));


--
-- Name: brand_edit_suggestions Enable delete for creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for creator" ON "public"."brand_edit_suggestions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: check_in_comments Enable delete for creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for creator" ON "public"."check_in_comments" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: company_edit_suggestions Enable delete for creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for creator" ON "public"."company_edit_suggestions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: product_edit_suggestion_subcategories Enable delete for creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for creator" ON "public"."product_edit_suggestion_subcategories" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."product_edit_suggestion_subcategories" "pess"
     LEFT JOIN "public"."product_edit_suggestions" "pes" ON (("pess"."product_edit_suggestion_id" = "pes"."id")))
  WHERE ("pes"."created_by" = "auth"."uid"()))));


--
-- Name: product_edit_suggestions Enable delete for creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for creator" ON "public"."product_edit_suggestions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: sub_brand_edit_suggestion Enable delete for creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for creator" ON "public"."sub_brand_edit_suggestion" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: check_in_tagged_profiles Enable delete for creator of the check in; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for creator of the check in" ON "public"."check_in_tagged_profiles" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_tagged_profiles"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));


--
-- Name: profile_push_notification_tokens Enable delete for owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for owner" ON "public"."profile_push_notification_tokens" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: check_in_reactions Enable delete for the creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for the creator" ON "public"."check_in_reactions" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: check_ins Enable delete for the creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for the creator" ON "public"."check_ins" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "created_by"));


--
-- Name: check_in_flavors Enable delete for the creator of the check in; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for the creator of the check in" ON "public"."check_in_flavors" FOR DELETE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_flavors"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));


--
-- Name: notifications Enable delete for the owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for the owner" ON "public"."notifications" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "profile_id"));


--
-- Name: brands Enable delete for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users with permission" ON "public"."brands" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_brands'::"text"));


--
-- Name: companies Enable delete for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users with permission" ON "public"."companies" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_companies'::"text"));


--
-- Name: product_variants Enable delete for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users with permission" ON "public"."product_variants" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_products'::"text"));


--
-- Name: products Enable delete for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users with permission" ON "public"."products" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_products'::"text"));


--
-- Name: products_subcategories Enable delete for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users with permission" ON "public"."products_subcategories" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_products'::"text"));


--
-- Name: sub_brands Enable delete for users with permission; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable delete for users with permission" ON "public"."sub_brands" FOR DELETE TO "authenticated" USING ("public"."fnc__has_permission"("auth"."uid"(), 'can_delete_brands'::"text"));


--
-- Name: products_subcategories Enable insert for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users" ON "public"."products_subcategories" FOR INSERT TO "authenticated" WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: brand_edit_suggestions Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."brand_edit_suggestions" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: brands Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."brands" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: check_in_comments Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."check_in_comments" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: check_in_reactions Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."check_in_reactions" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: check_ins Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."check_ins" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: companies Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."companies" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: company_edit_suggestions Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."company_edit_suggestions" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: friends Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."friends" FOR INSERT TO "authenticated" WITH CHECK (("user_id_1" = "auth"."uid"()));


--
-- Name: locations Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."locations" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: product_edit_suggestion_subcategories Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_edit_suggestion_subcategories" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: product_edit_suggestions Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_edit_suggestions" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: product_variants Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."product_variants" FOR INSERT TO "authenticated" WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: products Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."products" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: profile_push_notification_tokens Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."profile_push_notification_tokens" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: sub_brand_edit_suggestion Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."sub_brand_edit_suggestion" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: sub_brands Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON "public"."sub_brands" FOR INSERT TO "authenticated" WITH CHECK (true);


--
-- Name: check_in_tagged_profiles Enable insert for creator of  the check in; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for creator of  the check in" ON "public"."check_in_tagged_profiles" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_tagged_profiles"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));


--
-- Name: check_in_flavors Enable insert for creator of the check in; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for creator of the check in" ON "public"."check_in_flavors" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."check_ins" "ci"
  WHERE (("ci"."id" = "check_in_flavors"."check_in_id") AND ("ci"."created_by" = "auth"."uid"())))));


--
-- Name: brand_edit_suggestions Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."brand_edit_suggestions" FOR SELECT USING (true);


--
-- Name: brands Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."brands" FOR SELECT USING (true);


--
-- Name: category_serving_styles Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."category_serving_styles" FOR SELECT USING (true);


--
-- Name: check_in_flavors Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."check_in_flavors" FOR SELECT USING (true);


--
-- Name: check_in_tagged_profiles Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."check_in_tagged_profiles" FOR SELECT USING (true);


--
-- Name: company_edit_suggestions Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."company_edit_suggestions" FOR SELECT USING (true);


--
-- Name: countries Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."countries" FOR SELECT USING (true);


--
-- Name: flavors Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."flavors" FOR SELECT USING (true);


--
-- Name: friends Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."friends" FOR SELECT USING (true);


--
-- Name: locations Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."locations" FOR SELECT USING (true);


--
-- Name: product_edit_suggestion_subcategories Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."product_edit_suggestion_subcategories" FOR SELECT USING (true);


--
-- Name: product_edit_suggestions Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."product_edit_suggestions" FOR SELECT USING (true);


--
-- Name: product_variants Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."product_variants" FOR SELECT USING (true);


--
-- Name: products_subcategories Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."products_subcategories" FOR SELECT TO "authenticated" USING (true);


--
-- Name: roles Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: serving_styles Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."serving_styles" FOR SELECT USING (true);


--
-- Name: sub_brand_edit_suggestion Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON "public"."sub_brand_edit_suggestion" FOR SELECT USING (true);


--
-- Name: notifications Enable read access for intended user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for intended user" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("profile_id" = "auth"."uid"()));


--
-- Name: profile_push_notification_tokens Enable read access for owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for owner" ON "public"."profile_push_notification_tokens" FOR SELECT TO "authenticated" USING (("created_by" = "auth"."uid"()));


--
-- Name: profile_settings Enable read access only to the owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access only to the owner" ON "public"."profile_settings" FOR SELECT TO "authenticated" USING (("id" = "auth"."uid"()));


--
-- Name: permissions Enable select for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable select for authenticated users only" ON "public"."permissions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: profiles_roles Enable select for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable select for authenticated users only" ON "public"."profiles_roles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: roles_permissions Enable select for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable select for authenticated users only" ON "public"."roles_permissions" FOR SELECT TO "authenticated" USING (true);


--
-- Name: friends Enable update for both sides of friend status ; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for both sides of friend status " ON "public"."friends" FOR UPDATE TO "authenticated" USING ((("user_id_1" = "auth"."uid"()) OR ("user_id_2" = "auth"."uid"()))) WITH CHECK ((("user_id_1" = "auth"."uid"()) OR ("user_id_2" = "auth"."uid"())));


--
-- Name: check_in_comments Enable update for creator of comment; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for creator of comment" ON "public"."check_in_comments" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "created_by")) WITH CHECK (("auth"."uid"() = "created_by"));


--
-- Name: profile_push_notification_tokens Enable update for owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for owner" ON "public"."profile_push_notification_tokens" FOR UPDATE TO "authenticated" USING (("created_by" = "auth"."uid"())) WITH CHECK (("created_by" = "auth"."uid"()));


--
-- Name: check_ins Enable update for the creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for the creator" ON "public"."check_ins" FOR UPDATE TO "authenticated" USING (("created_by" = "auth"."uid"()));


--
-- Name: profile_settings Enable update for the owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for the owner" ON "public"."profile_settings" FOR UPDATE TO "authenticated" USING (("id" = "auth"."uid"())) WITH CHECK (("id" = "auth"."uid"()));


--
-- Name: brands Forbid deleting verified; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Forbid deleting verified" ON "public"."brands" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));


--
-- Name: companies Forbid deleting verified; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Forbid deleting verified" ON "public"."companies" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));


--
-- Name: product_variants Forbid deleting verified; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Forbid deleting verified" ON "public"."product_variants" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));


--
-- Name: products Forbid deleting verified; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Forbid deleting verified" ON "public"."products" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));


--
-- Name: sub_brands Forbid deleting verified; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Forbid deleting verified" ON "public"."sub_brands" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));


--
-- Name: subcategories Forbid deleting verified; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Forbid deleting verified" ON "public"."subcategories" AS RESTRICTIVE FOR DELETE TO "authenticated" USING (("is_verified" = false));


--
-- Name: products Products are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Products are viewable by everyone." ON "public"."products" FOR SELECT USING (true);


--
-- Name: profiles Public profiles are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Public profiles are viewable by everyone." ON "public"."profiles" FOR SELECT USING (true);


--
-- Name: sub_brands Sub-brands are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Sub-brands are viewable by everyone." ON "public"."sub_brands" FOR SELECT USING (true);


--
-- Name: subcategories Subcategories are viewable by everyone.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Subcategories are viewable by everyone." ON "public"."subcategories" FOR SELECT USING (true);


--
-- Name: profiles Users can delete own profile.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can delete own profile." ON "public"."profiles" FOR DELETE TO "authenticated" USING (("auth"."uid"() = "id"));


--
-- Name: profiles Users can update own profile.; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own profile." ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id"));


--
-- Name: brand_edit_suggestions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."brand_edit_suggestions" ENABLE ROW LEVEL SECURITY;

--
-- Name: brands; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."brands" ENABLE ROW LEVEL SECURITY;

--
-- Name: categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;

--
-- Name: category_serving_styles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."category_serving_styles" ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_comments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_in_comments" ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_flavors; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_in_flavors" ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_reactions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_in_reactions" ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_tagged_profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_in_tagged_profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: check_ins; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."check_ins" ENABLE ROW LEVEL SECURITY;

--
-- Name: companies; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."companies" ENABLE ROW LEVEL SECURITY;

--
-- Name: company_edit_suggestions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."company_edit_suggestions" ENABLE ROW LEVEL SECURITY;

--
-- Name: countries; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."countries" ENABLE ROW LEVEL SECURITY;

--
-- Name: flavors; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."flavors" ENABLE ROW LEVEL SECURITY;

--
-- Name: friends; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."friends" ENABLE ROW LEVEL SECURITY;

--
-- Name: locations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."locations" ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

--
-- Name: permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_edit_suggestion_subcategories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_edit_suggestion_subcategories" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_edit_suggestions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_edit_suggestions" ENABLE ROW LEVEL SECURITY;

--
-- Name: product_variants; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."product_variants" ENABLE ROW LEVEL SECURITY;

--
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;

--
-- Name: products_subcategories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."products_subcategories" ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_push_notification_tokens; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profile_push_notification_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profile_settings" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles_roles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profiles_roles" ENABLE ROW LEVEL SECURITY;

--
-- Name: roles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;

--
-- Name: roles_permissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."roles_permissions" ENABLE ROW LEVEL SECURITY;

--
-- Name: secrets; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."secrets" ENABLE ROW LEVEL SECURITY;

--
-- Name: serving_styles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."serving_styles" ENABLE ROW LEVEL SECURITY;

--
-- Name: sub_brand_edit_suggestion; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."sub_brand_edit_suggestion" ENABLE ROW LEVEL SECURITY;

--
-- Name: sub_brands; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."sub_brands" ENABLE ROW LEVEL SECURITY;

--
-- Name: subcategories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."subcategories" ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA "net"; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA "net" TO "supabase_functions_admin";
GRANT USAGE ON SCHEMA "net" TO "anon";
GRANT USAGE ON SCHEMA "net" TO "authenticated";
GRANT USAGE ON SCHEMA "net" TO "service_role";


--
-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


--
-- Name: FUNCTION "citextin"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citextin"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."citextin"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextin"("cstring") TO "service_role";


--
-- Name: FUNCTION "citextout"("public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citextout"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citextout"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextout"("public"."citext") TO "service_role";


--
-- Name: FUNCTION "citextrecv"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citextrecv"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."citextrecv"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextrecv"("internal") TO "service_role";


--
-- Name: FUNCTION "citextsend"("public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citextsend"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citextsend"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citextsend"("public"."citext") TO "service_role";


--
-- Name: FUNCTION "gtrgm_in"("cstring"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "service_role";


--
-- Name: FUNCTION "gtrgm_out"("public"."gtrgm"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "service_role";


--
-- Name: FUNCTION "citext"(boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext"(boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."citext"(boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext"(boolean) TO "service_role";


--
-- Name: FUNCTION "citext"(character); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext"(character) TO "anon";
GRANT ALL ON FUNCTION "public"."citext"(character) TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext"(character) TO "service_role";


--
-- Name: FUNCTION "citext"("inet"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext"("inet") TO "anon";
GRANT ALL ON FUNCTION "public"."citext"("inet") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext"("inet") TO "service_role";


--
-- Name: FUNCTION "job_cache_invalidate"(); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "cron"."job_cache_invalidate"() TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "schedule"("schedule" "text", "command" "text"); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "cron"."schedule"("schedule" "text", "command" "text") TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "schedule"("job_name" "text", "schedule" "text", "command" "text"); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "cron"."schedule"("job_name" "text", "schedule" "text", "command" "text") TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "unschedule"("job_id" bigint); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "cron"."unschedule"("job_id" bigint) TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "unschedule"("job_name" "name"); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "cron"."unschedule"("job_name" "name") TO "postgres" WITH GRANT OPTION;


--
-- Name: FUNCTION "algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "armor"("bytea", "text"[], "text"[]); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "dashboard_user";


--
-- Name: FUNCTION "crypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "dearmor"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "decrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "digest"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "encrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_bytes"(integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "dashboard_user";


--
-- Name: FUNCTION "gen_random_uuid"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "dashboard_user";


--
-- Name: FUNCTION "gen_salt"("text", integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "hmac"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "dashboard_user";


--
-- Name: FUNCTION "pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "dashboard_user";


--
-- Name: FUNCTION "pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_key_id"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "dashboard_user";


--
-- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "dashboard_user";


--
-- Name: FUNCTION "sign"("payload" "json", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "try_cast_double"("inp" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_decode"("data" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "dashboard_user";


--
-- Name: FUNCTION "url_encode"("data" "bytea"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v1mc"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v3"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v4"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_generate_v5"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "dashboard_user";


--
-- Name: FUNCTION "uuid_nil"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_dns"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_oid"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_url"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "dashboard_user";


--
-- Name: FUNCTION "uuid_ns_x500"(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "dashboard_user";


--
-- Name: FUNCTION "verify"("token" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "http_collect_response"("request_id" bigint, "async" boolean); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "supabase_functions_admin";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "postgres";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "anon";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "net"."http_collect_response"("request_id" bigint, "async" boolean) TO "service_role";


--
-- Name: FUNCTION "http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "supabase_functions_admin";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "postgres";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "anon";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "authenticated";
GRANT ALL ON FUNCTION "net"."http_get"("url" "text", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "service_role";


--
-- Name: FUNCTION "http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) FROM PUBLIC;
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "supabase_functions_admin";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "postgres";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "anon";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "authenticated";
GRANT ALL ON FUNCTION "net"."http_post"("url" "text", "body" "jsonb", "params" "jsonb", "headers" "jsonb", "timeout_milliseconds" integer) TO "service_role";


--
-- Name: SEQUENCE "key_key_id_seq"; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON SEQUENCE "pgsodium"."key_key_id_seq" TO "pgsodium_keyiduser";


--
-- Name: FUNCTION "citext_cmp"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_cmp"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_cmp"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_cmp"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_eq"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_eq"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_eq"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_eq"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_ge"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_ge"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_ge"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_ge"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_gt"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_gt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_gt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_gt"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_hash"("public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_hash"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_hash"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_hash"("public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_hash_extended"("public"."citext", bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_hash_extended"("public"."citext", bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."citext_hash_extended"("public"."citext", bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_hash_extended"("public"."citext", bigint) TO "service_role";


--
-- Name: FUNCTION "citext_larger"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_larger"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_larger"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_larger"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_le"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_le"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_le"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_le"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_lt"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_lt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_lt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_lt"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_ne"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_ne"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_ne"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_ne"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_pattern_cmp"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_pattern_cmp"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_cmp"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_cmp"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_pattern_ge"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_pattern_ge"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_ge"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_ge"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_pattern_gt"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_pattern_gt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_gt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_gt"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_pattern_le"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_pattern_le"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_le"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_le"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_pattern_lt"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_pattern_lt"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_pattern_lt"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_pattern_lt"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "citext_smaller"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."citext_smaller"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."citext_smaller"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."citext_smaller"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "fnc__accept_friend_request"("user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__accept_friend_request"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__accept_friend_request"("user_id" "uuid") TO "service_role";


--
-- Name: TABLE "check_ins"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."check_ins" TO "authenticated";
GRANT ALL ON TABLE "public"."check_ins" TO "anon";
GRANT ALL ON TABLE "public"."check_ins" TO "service_role";


--
-- Name: FUNCTION "fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_check_in"("p_product_id" bigint, "p_rating" numeric, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") TO "service_role";


--
-- Name: TABLE "company_edit_suggestions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."company_edit_suggestions" TO "anon";
GRANT ALL ON TABLE "public"."company_edit_suggestions" TO "authenticated";
GRANT ALL ON TABLE "public"."company_edit_suggestions" TO "service_role";


--
-- Name: FUNCTION "fnc__create_company_edit_suggestion"("p_company_id" bigint, "p_name" "text", "p_logo_url" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__create_company_edit_suggestion"("p_company_id" bigint, "p_name" "text", "p_logo_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_company_edit_suggestion"("p_company_id" bigint, "p_name" "text", "p_logo_url" "text") TO "service_role";


--
-- Name: TABLE "products"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";


--
-- Name: FUNCTION "fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_product"("p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_brand_id" bigint, "p_sub_brand_id" bigint) TO "service_role";


--
-- Name: TABLE "product_edit_suggestions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_edit_suggestions" TO "anon";
GRANT ALL ON TABLE "public"."product_edit_suggestions" TO "authenticated";
GRANT ALL ON TABLE "public"."product_edit_suggestions" TO "service_role";


--
-- Name: FUNCTION "fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__create_product_edit_suggestion"("p_product_id" bigint, "p_name" "text", "p_description" "text", "p_category_id" bigint, "p_sub_category_ids" bigint[], "p_sub_brand_id" bigint) TO "service_role";


--
-- Name: FUNCTION "fnc__current_user_has_permission"("p_permission_name" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__current_user_has_permission"("p_permission_name" "text") TO "service_role";


--
-- Name: FUNCTION "fnc__delete_current_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__delete_current_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__delete_current_user"() TO "service_role";


--
-- Name: FUNCTION "fnc__export_data"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__export_data"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__export_data"() TO "service_role";


--
-- Name: FUNCTION "fnc__get_activity_feed"("p_created_after" "date"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_activity_feed"("p_created_after" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_activity_feed"("p_created_after" "date") TO "service_role";


--
-- Name: FUNCTION "fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_reaction_notification"("p_check_in_reaction_id" bigint) TO "service_role";


--
-- Name: FUNCTION "fnc__get_check_in_tag_notification"("p_check_in_tag" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_check_in_tag_notification"("p_check_in_tag" bigint) TO "service_role";


--
-- Name: FUNCTION "fnc__get_company_summary"("p_company_id" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_company_summary"("p_company_id" integer) TO "service_role";


--
-- Name: FUNCTION "fnc__get_edge_function_authorization_header"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_authorization_header"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_authorization_header"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_authorization_header"() TO "service_role";


--
-- Name: FUNCTION "fnc__get_edge_function_url"("p_function_name" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_edge_function_url"("p_function_name" "text") TO "service_role";


--
-- Name: FUNCTION "fnc__get_friend_request_notification"("p_friend_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_friend_request_notification"("p_friend_id" bigint) TO "service_role";


--
-- Name: FUNCTION "fnc__get_product_summary"("p_product_id" integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_product_summary"("p_product_id" integer) TO "service_role";


--
-- Name: FUNCTION "fnc__get_profile_summary"("p_uid" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_profile_summary"("p_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_profile_summary"("p_uid" "uuid") TO "service_role";


--
-- Name: FUNCTION "fnc__get_push_notification_request"("p_receiver_id" "uuid", "p_notification" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_id" "uuid", "p_notification" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_id" "uuid", "p_notification" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__get_push_notification_request"("p_receiver_id" "uuid", "p_notification" "jsonb") TO "service_role";


--
-- Name: FUNCTION "fnc__has_permission"("p_uid" "uuid", "p_permission_name" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__has_permission"("p_uid" "uuid", "p_permission_name" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__has_permission"("p_uid" "uuid", "p_permission_name" "text") TO "service_role";


--
-- Name: FUNCTION "fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__merge_products"("p_product_id" bigint, "p_to_product_id" bigint) TO "service_role";


--
-- Name: FUNCTION "fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__post_request"("url" "text", "headers" "jsonb", "body" "jsonb") TO "service_role";


--
-- Name: FUNCTION "fnc__refresh_firebase_access_token"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__refresh_firebase_access_token"() TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__refresh_firebase_access_token"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__refresh_firebase_access_token"() TO "service_role";


--
-- Name: FUNCTION "fnc__search_products"("p_search_term" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__search_products"("p_search_term" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__search_products"("p_search_term" "text") TO "service_role";


--
-- Name: TABLE "profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";


--
-- Name: FUNCTION "fnc__search_profiles"("p_search_term" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__search_profiles"("p_search_term" "text") TO "service_role";


--
-- Name: FUNCTION "fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" integer, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" integer, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" integer, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__update_check_in"("p_check_in_id" bigint, "p_product_id" bigint, "p_rating" integer, "p_review" "text", "p_manufacturer_id" bigint, "p_serving_style_id" bigint, "p_friend_ids" "uuid"[], "p_flavor_ids" bigint[], "p_location_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "fnc__upsert_push_notification_token"("p_push_notification_token" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fnc__upsert_push_notification_token"("p_push_notification_token" "text") TO "service_role";


--
-- Name: FUNCTION "gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "gin_extract_value_trgm"("text", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "service_role";


--
-- Name: FUNCTION "gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_compress"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_consistent"("internal", "text", smallint, "oid", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_decompress"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_distance"("internal", "text", smallint, "oid", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_options"("internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_penalty"("internal", "internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_picksplit"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "service_role";


--
-- Name: FUNCTION "gtrgm_union"("internal", "internal"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "service_role";


--
-- Name: FUNCTION "regexp_match"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "regexp_match"("public"."citext", "public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_match"("public"."citext", "public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "regexp_matches"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "regexp_matches"("public"."citext", "public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_matches"("public"."citext", "public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "regexp_replace"("public"."citext", "public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "regexp_replace"("public"."citext", "public"."citext", "text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_replace"("public"."citext", "public"."citext", "text", "text") TO "service_role";


--
-- Name: FUNCTION "regexp_split_to_array"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "regexp_split_to_array"("public"."citext", "public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_array"("public"."citext", "public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "regexp_split_to_table"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "regexp_split_to_table"("public"."citext", "public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."regexp_split_to_table"("public"."citext", "public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "replace"("public"."citext", "public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."replace"("public"."citext", "public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."replace"("public"."citext", "public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."replace"("public"."citext", "public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "set_limit"(real); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "anon";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "service_role";


--
-- Name: FUNCTION "show_limit"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."show_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "service_role";


--
-- Name: FUNCTION "show_trgm"("text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "service_role";


--
-- Name: FUNCTION "similarity"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "service_role";


--
-- Name: FUNCTION "similarity_dist"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "service_role";


--
-- Name: FUNCTION "similarity_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "split_part"("public"."citext", "public"."citext", integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."split_part"("public"."citext", "public"."citext", integer) TO "anon";
GRANT ALL ON FUNCTION "public"."split_part"("public"."citext", "public"."citext", integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."split_part"("public"."citext", "public"."citext", integer) TO "service_role";


--
-- Name: FUNCTION "strict_word_similarity"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "service_role";


--
-- Name: FUNCTION "strict_word_similarity_commutator_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "strict_word_similarity_dist_commutator_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "strict_word_similarity_dist_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "strict_word_similarity_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "strpos"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."strpos"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."strpos"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strpos"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "texticlike"("public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "texticlike"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticlike"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "texticnlike"("public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "texticnlike"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticnlike"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "texticregexeq"("public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "texticregexeq"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexeq"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "texticregexne"("public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "texticregexne"("public"."citext", "public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."texticregexne"("public"."citext", "public"."citext") TO "service_role";


--
-- Name: FUNCTION "tg__check_friend_status_transition"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__check_friend_status_transition"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__check_friend_status_transition"() TO "service_role";


--
-- Name: FUNCTION "tg__check_subcategory_constraint"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__check_subcategory_constraint"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__check_subcategory_constraint"() TO "service_role";


--
-- Name: FUNCTION "tg__clean_up_check_in"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__clean_up_check_in"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__clean_up_check_in"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__clean_up_check_in"() TO "service_role";


--
-- Name: FUNCTION "tg__create_default_sub_brand"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__create_default_sub_brand"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_default_sub_brand"() TO "service_role";


--
-- Name: FUNCTION "tg__create_friend_request"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__create_friend_request"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_friend_request"() TO "service_role";


--
-- Name: FUNCTION "tg__create_profile_for_new_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__create_profile_for_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_profile_for_new_user"() TO "service_role";


--
-- Name: FUNCTION "tg__create_profile_settings"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__create_profile_settings"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__create_profile_settings"() TO "service_role";


--
-- Name: FUNCTION "tg__forbid_changing_check_in_id"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__forbid_changing_check_in_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__forbid_changing_check_in_id"() TO "service_role";


--
-- Name: FUNCTION "tg__forbid_send_messages_too_often"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__forbid_send_messages_too_often"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__forbid_send_messages_too_often"() TO "service_role";


--
-- Name: FUNCTION "tg__friend_request_check"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__friend_request_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__friend_request_check"() TO "service_role";


--
-- Name: FUNCTION "tg__is_verified_check"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__is_verified_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__is_verified_check"() TO "service_role";


--
-- Name: FUNCTION "tg__make_id_immutable"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__make_id_immutable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__make_id_immutable"() TO "service_role";


--
-- Name: FUNCTION "tg__must_be_friends"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__must_be_friends"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__must_be_friends"() TO "service_role";


--
-- Name: FUNCTION "tg__refresh_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__refresh_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__refresh_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__refresh_updated_at"() TO "service_role";


--
-- Name: FUNCTION "tg__remove_unused_tokens"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__remove_unused_tokens"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__remove_unused_tokens"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__remove_unused_tokens"() TO "service_role";


--
-- Name: FUNCTION "tg__send_check_in_reaction_notification"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__send_check_in_reaction_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_check_in_reaction_notification"() TO "service_role";


--
-- Name: FUNCTION "tg__send_friend_request_notification"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__send_friend_request_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_friend_request_notification"() TO "service_role";


--
-- Name: FUNCTION "tg__send_push_notification"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__send_push_notification"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__send_push_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_push_notification"() TO "service_role";


--
-- Name: FUNCTION "tg__send_tagged_in_check_in_notification"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__send_tagged_in_check_in_notification"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__send_tagged_in_check_in_notification"() TO "service_role";


--
-- Name: FUNCTION "tg__set_avatar_on_upload"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__set_avatar_on_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__set_avatar_on_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__set_avatar_on_upload"() TO "service_role";


--
-- Name: FUNCTION "tg__set_check_in_image_on_upload"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__set_check_in_image_on_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__set_check_in_image_on_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__set_check_in_image_on_upload"() TO "service_role";


--
-- Name: FUNCTION "tg__stamp_created_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__stamp_created_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__stamp_created_at"() TO "service_role";


--
-- Name: FUNCTION "tg__stamp_created_by"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__stamp_created_by"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__stamp_created_by"() TO "service_role";


--
-- Name: FUNCTION "tg__stamp_updated_at"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__stamp_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__stamp_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__stamp_updated_at"() TO "service_role";


--
-- Name: FUNCTION "tg__trim_description_empty_check"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__trim_description_empty_check"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__trim_description_empty_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__trim_description_empty_check"() TO "service_role";


--
-- Name: FUNCTION "tg__trim_name_empty_check"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."tg__trim_name_empty_check"() TO "anon";
GRANT ALL ON FUNCTION "public"."tg__trim_name_empty_check"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."tg__trim_name_empty_check"() TO "service_role";


--
-- Name: FUNCTION "translate"("public"."citext", "public"."citext", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."translate"("public"."citext", "public"."citext", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."translate"("public"."citext", "public"."citext", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."translate"("public"."citext", "public"."citext", "text") TO "service_role";


--
-- Name: FUNCTION "word_similarity"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "service_role";


--
-- Name: FUNCTION "word_similarity_commutator_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "word_similarity_dist_commutator_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "word_similarity_dist_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "word_similarity_op"("text", "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "service_role";


--
-- Name: FUNCTION "max"("public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."max"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."max"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."max"("public"."citext") TO "service_role";


--
-- Name: FUNCTION "min"("public"."citext"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."min"("public"."citext") TO "anon";
GRANT ALL ON FUNCTION "public"."min"("public"."citext") TO "authenticated";
GRANT ALL ON FUNCTION "public"."min"("public"."citext") TO "service_role";


--
-- Name: SEQUENCE "jobid_seq"; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "cron"."jobid_seq" TO "postgres" WITH GRANT OPTION;


--
-- Name: SEQUENCE "runid_seq"; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE "cron"."runid_seq" TO "postgres" WITH GRANT OPTION;


--
-- Name: TABLE "pg_stat_statements"; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "dashboard_user";


--
-- Name: TABLE "pg_stat_statements_info"; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "dashboard_user";


--
-- Name: TABLE "valid_key"; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON TABLE "pgsodium"."valid_key" TO "pgsodium_keyiduser";


--
-- Name: TABLE "brand_edit_suggestions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."brand_edit_suggestions" TO "anon";
GRANT ALL ON TABLE "public"."brand_edit_suggestions" TO "authenticated";
GRANT ALL ON TABLE "public"."brand_edit_suggestions" TO "service_role";


--
-- Name: SEQUENCE "brand_edit_suggestions_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."brand_edit_suggestions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."brand_edit_suggestions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."brand_edit_suggestions_id_seq" TO "service_role";


--
-- Name: TABLE "brands"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."brands" TO "anon";
GRANT ALL ON TABLE "public"."brands" TO "authenticated";
GRANT ALL ON TABLE "public"."brands" TO "service_role";


--
-- Name: SEQUENCE "brands_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."brands_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."brands_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."brands_id_seq" TO "service_role";


--
-- Name: TABLE "categories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."categories" TO "anon";
GRANT ALL ON TABLE "public"."categories" TO "authenticated";
GRANT ALL ON TABLE "public"."categories" TO "service_role";


--
-- Name: SEQUENCE "categories_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."categories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."categories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."categories_id_seq" TO "service_role";


--
-- Name: TABLE "category_serving_styles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."category_serving_styles" TO "anon";
GRANT ALL ON TABLE "public"."category_serving_styles" TO "authenticated";
GRANT ALL ON TABLE "public"."category_serving_styles" TO "service_role";


--
-- Name: TABLE "check_in_comments"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."check_in_comments" TO "anon";
GRANT ALL ON TABLE "public"."check_in_comments" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_comments" TO "service_role";


--
-- Name: SEQUENCE "check_in_comments_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."check_in_comments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."check_in_comments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."check_in_comments_id_seq" TO "service_role";


--
-- Name: TABLE "check_in_flavors"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."check_in_flavors" TO "anon";
GRANT ALL ON TABLE "public"."check_in_flavors" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_flavors" TO "service_role";


--
-- Name: TABLE "check_in_reactions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."check_in_reactions" TO "anon";
GRANT ALL ON TABLE "public"."check_in_reactions" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_reactions" TO "service_role";


--
-- Name: SEQUENCE "check_in_reactions_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."check_in_reactions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."check_in_reactions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."check_in_reactions_id_seq" TO "service_role";


--
-- Name: TABLE "check_in_tagged_profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."check_in_tagged_profiles" TO "anon";
GRANT ALL ON TABLE "public"."check_in_tagged_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."check_in_tagged_profiles" TO "service_role";


--
-- Name: SEQUENCE "check_ins_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."check_ins_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."check_ins_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."check_ins_id_seq" TO "service_role";


--
-- Name: TABLE "companies"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."companies" TO "authenticated";
GRANT ALL ON TABLE "public"."companies" TO "anon";
GRANT ALL ON TABLE "public"."companies" TO "service_role";


--
-- Name: SEQUENCE "companies_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."companies_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."companies_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."companies_id_seq" TO "service_role";


--
-- Name: SEQUENCE "company_edit_suggestions_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."company_edit_suggestions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."company_edit_suggestions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."company_edit_suggestions_id_seq" TO "service_role";


--
-- Name: TABLE "countries"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."countries" TO "anon";
GRANT ALL ON TABLE "public"."countries" TO "authenticated";
GRANT ALL ON TABLE "public"."countries" TO "service_role";


--
-- Name: TABLE "flavors"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."flavors" TO "anon";
GRANT ALL ON TABLE "public"."flavors" TO "authenticated";
GRANT ALL ON TABLE "public"."flavors" TO "service_role";


--
-- Name: SEQUENCE "flavors_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."flavors_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."flavors_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."flavors_id_seq" TO "service_role";


--
-- Name: TABLE "friends"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."friends" TO "authenticated";
GRANT ALL ON TABLE "public"."friends" TO "anon";
GRANT ALL ON TABLE "public"."friends" TO "service_role";


--
-- Name: SEQUENCE "friends_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."friends_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."friends_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."friends_id_seq" TO "service_role";


--
-- Name: TABLE "locations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."locations" TO "anon";
GRANT ALL ON TABLE "public"."locations" TO "authenticated";
GRANT ALL ON TABLE "public"."locations" TO "service_role";


--
-- Name: TABLE "notifications"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";


--
-- Name: SEQUENCE "notifications_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "service_role";


--
-- Name: TABLE "permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."permissions" TO "anon";
GRANT ALL ON TABLE "public"."permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."permissions" TO "service_role";


--
-- Name: SEQUENCE "permissions_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."permissions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."permissions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."permissions_id_seq" TO "service_role";


--
-- Name: TABLE "product_edit_suggestion_subcategories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_edit_suggestion_subcategories" TO "anon";
GRANT ALL ON TABLE "public"."product_edit_suggestion_subcategories" TO "authenticated";
GRANT ALL ON TABLE "public"."product_edit_suggestion_subcategories" TO "service_role";


--
-- Name: SEQUENCE "product_edit_suggestion_subcategories_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestion_subcategories_id_seq" TO "service_role";


--
-- Name: SEQUENCE "product_edit_suggestions_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."product_edit_suggestions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_edit_suggestions_id_seq" TO "service_role";


--
-- Name: TABLE "product_variants"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."product_variants" TO "authenticated";
GRANT ALL ON TABLE "public"."product_variants" TO "anon";
GRANT ALL ON TABLE "public"."product_variants" TO "service_role";


--
-- Name: SEQUENCE "product_variants_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."product_variants_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_variants_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_variants_id_seq" TO "service_role";


--
-- Name: SEQUENCE "products_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "service_role";


--
-- Name: TABLE "products_subcategories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."products_subcategories" TO "anon";
GRANT ALL ON TABLE "public"."products_subcategories" TO "authenticated";
GRANT ALL ON TABLE "public"."products_subcategories" TO "service_role";


--
-- Name: SEQUENCE "products_subcategories_product_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."products_subcategories_product_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_subcategories_product_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_subcategories_product_id_seq" TO "service_role";


--
-- Name: TABLE "profile_push_notification_tokens"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profile_push_notification_tokens" TO "anon";
GRANT ALL ON TABLE "public"."profile_push_notification_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_push_notification_tokens" TO "service_role";


--
-- Name: TABLE "profile_settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profile_settings" TO "anon";
GRANT ALL ON TABLE "public"."profile_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_settings" TO "service_role";


--
-- Name: TABLE "profiles_roles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profiles_roles" TO "anon";
GRANT ALL ON TABLE "public"."profiles_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles_roles" TO "service_role";


--
-- Name: TABLE "roles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";


--
-- Name: SEQUENCE "roles_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."roles_id_seq" TO "service_role";


--
-- Name: TABLE "roles_permissions"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."roles_permissions" TO "anon";
GRANT ALL ON TABLE "public"."roles_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."roles_permissions" TO "service_role";


--
-- Name: TABLE "secrets"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."secrets" TO "anon";
GRANT ALL ON TABLE "public"."secrets" TO "authenticated";
GRANT ALL ON TABLE "public"."secrets" TO "service_role";


--
-- Name: TABLE "serving_styles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."serving_styles" TO "anon";
GRANT ALL ON TABLE "public"."serving_styles" TO "authenticated";
GRANT ALL ON TABLE "public"."serving_styles" TO "service_role";


--
-- Name: SEQUENCE "serving_styles_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."serving_styles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."serving_styles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."serving_styles_id_seq" TO "service_role";


--
-- Name: TABLE "sub_brand_edit_suggestion"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."sub_brand_edit_suggestion" TO "anon";
GRANT ALL ON TABLE "public"."sub_brand_edit_suggestion" TO "authenticated";
GRANT ALL ON TABLE "public"."sub_brand_edit_suggestion" TO "service_role";


--
-- Name: SEQUENCE "sub_brand_edit_suggestion_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."sub_brand_edit_suggestion_id_seq" TO "service_role";


--
-- Name: TABLE "sub_brands"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."sub_brands" TO "anon";
GRANT ALL ON TABLE "public"."sub_brands" TO "authenticated";
GRANT ALL ON TABLE "public"."sub_brands" TO "service_role";


--
-- Name: SEQUENCE "sub_brands_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."sub_brands_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."sub_brands_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."sub_brands_id_seq" TO "service_role";


--
-- Name: TABLE "subcategories"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."subcategories" TO "anon";
GRANT ALL ON TABLE "public"."subcategories" TO "authenticated";
GRANT ALL ON TABLE "public"."subcategories" TO "service_role";


--
-- Name: SEQUENCE "subcategories_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."subcategories_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."subcategories_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."subcategories_id_seq" TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "cron" GRANT ALL ON SEQUENCES  TO "postgres" WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "cron" GRANT ALL ON FUNCTIONS  TO "postgres" WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "cron" GRANT ALL ON TABLES  TO "postgres" WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- PostgreSQL database dump complete
--

RESET ALL;
