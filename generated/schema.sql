--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

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
-- Name: tasted_hidden; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tasted_hidden;


--
-- Name: tasted_private; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tasted_private;


--
-- Name: tasted_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tasted_public;


--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: long_text; Type: DOMAIN; Schema: tasted_public; Owner: -
--

CREATE DOMAIN tasted_public.long_text AS text
	CONSTRAINT long_text_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 56)));


--
-- Name: medium_text; Type: DOMAIN; Schema: tasted_public; Owner: -
--

CREATE DOMAIN tasted_public.medium_text AS text
	CONSTRAINT medium_text_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 128)));


--
-- Name: short_text; Type: DOMAIN; Schema: tasted_public; Owner: -
--

CREATE DOMAIN tasted_public.short_text AS text
	CONSTRAINT short_text_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 56)));


--
-- Name: assert_valid_password(text); Type: FUNCTION; Schema: tasted_private; Owner: -
--

CREATE FUNCTION tasted_private.assert_valid_password(new_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  if (select new_password ~ '\d' = false) then
    raise exception 'password must contain numbers' using errcode = 'WEAKP';
  end if;
  if (select new_password ~ '[a-zA-Z]' = false) then
    raise exception 'password must contain letters' using errcode = 'WEAKP';
  end if;
  if length(new_password) <= 8 then
    raise exception 'password must be at least 8 characters long' using errcode = 'WEAKP';
  end if;
end;
$$;


--
-- Name: migrate_seed(); Type: PROCEDURE; Schema: tasted_private; Owner: -
--

CREATE PROCEDURE tasted_private.migrate_seed()
    LANGUAGE sql
    AS $$
insert into tasted_public.companies (name)
select distinct company as name
from tasted_private.transferable_check_ins
on conflict do nothing;
insert into tasted_public.categories (name)
select distinct category as name
from tasted_private.transferable_check_ins
on conflict do nothing;
with types as (
  select distinct category,
                  style as name
  from tasted_private.transferable_check_ins
)
insert
into tasted_public.types (name, category)
select name,
       category
from types
on conflict do nothing;
with brands as (
  select distinct brand,
                  company
  from tasted_private.transferable_check_ins
)
insert
into tasted_public.brands (name, company_id)
select b.brand as name,
       c.id    as company_id
from brands b
       left join tasted_public.companies c on b.company = c.name
on conflict do nothing;
with products as (
  select b.id as brand_id,
         p.flavor as name,
         c.id as manufacturer_id,
         t.id as type_id
  from tasted_private.transferable_check_ins p
         left join tasted_public.companies c on p.company = c.name
         left join tasted_public.types t on p.style = t.name
    and p.category = t.category
         left join tasted_public.brands b on p.brand = b.name
    and b.company_id = c.id
)
insert
into tasted_public.products (name, brand_id, manufacturer_id, type_id)
select name,
       brand_id,
       manufacturer_id,
       type_id
from products
on conflict do nothing;
with check_ins as (
  select case
           when length(p.rating) > 0 then (
             replace(p.rating, ',', '.')::decimal * 2
             )::integer
           else null
           end as rating,
         i.id  as product_id
  from tasted_private.transferable_check_ins p
         left join tasted_public.companies c on p.company = c.name
         left join tasted_public.brands b on b.company_id = c.id
    and b.name = p.brand
         left join tasted_public.categories k on k.name = p.category
         left join tasted_public.types t on t.category = k.name
    and p.style = t.name
         left join tasted_public.products i on i.manufacturer_id = c.id
    and b.id = i.brand_id
    and i.name = p.flavor
    and i.type_id = t.id
)
insert
into tasted_public.check_ins (rating, product_id, author_id)
select rating,
       i.product_id as product_id,
       (
         select id
         from tasted_public.users
         where username = 'villeheikkila'
       )         as author_id
from check_ins i
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users; Type: TABLE; Schema: tasted_public; Owner: -
--

CREATE TABLE tasted_public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username public.citext NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    first_name tasted_public.short_text,
    last_name tasted_public.short_text,
    CONSTRAINT users_username_check CHECK (((length((username)::text) >= 2) AND (length((username)::text) <= 24) AND (username OPERATOR(public.~) '^[a-zA-Z]([_]?[a-zA-Z0-9])+$'::public.citext)))
);


--
-- Name: really_create_user(public.citext, text); Type: FUNCTION; Schema: tasted_private; Owner: -
--

CREATE FUNCTION tasted_private.really_create_user(username public.citext, password text DEFAULT NULL::text) RETURNS tasted_public.users
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user     tasted_public.users;
  v_username citext = username;
begin
  if password is not null then
    perform tasted_private.assert_valid_password(password);
  end if;

  insert into tasted_public.users (username)
  values (v_username, name)
  returning * into v_user;

  if password is not null then
    update tasted_private.user_secrets
    set password_hash = crypt(password, gen_salt('bf'))
    where user_id = v_user.id;
  end if;

  select * into v_user from tasted_public.users where id = v_user.id;
  return v_user;
end;
$$;


--
-- Name: tg__timestamps(); Type: FUNCTION; Schema: tasted_private; Owner: -
--

CREATE FUNCTION tasted_private.tg__timestamps() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  NEW.created_at = (case when TG_OP = 'INSERT' then NOW() else OLD.created_at end);
  NEW.updated_at = (case when TG_OP = 'UPDATE' and OLD.updated_at >= NOW() then OLD.updated_at + interval '1 millisecond' else NOW() end);
  return NEW;
end;
$$;


--
-- Name: login(public.citext, text); Type: FUNCTION; Schema: tasted_public; Owner: -
--

CREATE FUNCTION tasted_public.login(username public.citext, password text) RETURNS tasted_public.users
    LANGUAGE plpgsql STRICT
    AS $$
declare
  v_user tasted_public.users;
  v_user_secret tasted_private.user_secrets;
begin
  select users.*
  into v_user
  from tasted_public.users
  where users.username = login.username;

  if not (v_user is null) then
    select *
    into v_user_secret
    from tasted_private.user_secrets
    where user_secrets.user_id = v_user.id;

    if v_user_secret.password_hash = crypt(password, v_user_secret.password_hash) then
      return v_user;
    else
      return null;
    end if;
  else
    return null;
  end if;
end;
$$;


--
-- Name: register(public.citext, text); Type: FUNCTION; Schema: tasted_public; Owner: -
--

CREATE FUNCTION tasted_public.register(username public.citext, password text DEFAULT NULL::text) RETURNS tasted_public.users
    LANGUAGE plpgsql STRICT
    AS $$
declare
  v_user     tasted_public.users;
  v_username citext = username;
begin
  perform tasted_private.assert_valid_password(password);
  insert into tasted_public.users (username)
  values (v_username)
  returning * into v_user;
  insert into tasted_private.user_secrets (user_id, password_hash)
  values (v_user.id, crypt(password, gen_salt('bf')));

  select * into v_user from tasted_public.users where id = v_user.id;
  return v_user;
end;
$$;


--
-- Name: transferable_check_ins; Type: TABLE; Schema: tasted_private; Owner: -
--

CREATE TABLE tasted_private.transferable_check_ins (
    company text,
    brand text,
    flavor text,
    category text,
    style text,
    rating text
);


--
-- Name: user_secrets; Type: TABLE; Schema: tasted_private; Owner: -
--

CREATE TABLE tasted_private.user_secrets (
    user_id uuid NOT NULL,
    password_hash text
);


--
-- Name: brands; Type: TABLE; Schema: tasted_public; Owner: -
--

CREATE TABLE tasted_public.brands (
    id integer NOT NULL,
    name tasted_public.medium_text,
    company_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid
);


--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: tasted_public; Owner: -
--

CREATE SEQUENCE tasted_public.brands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_id_seq; Type: SEQUENCE OWNED BY; Schema: tasted_public; Owner: -
--

ALTER SEQUENCE tasted_public.brands_id_seq OWNED BY tasted_public.brands.id;


--
-- Name: categories; Type: TABLE; Schema: tasted_public; Owner: -
--

CREATE TABLE tasted_public.categories (
    name character varying(40) NOT NULL
);


--
-- Name: check_ins; Type: TABLE; Schema: tasted_public; Owner: -
--

CREATE TABLE tasted_public.check_ins (
    id integer NOT NULL,
    rating integer,
    review text,
    product_id integer NOT NULL,
    author_id uuid NOT NULL,
    check_in_date date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT check_ins_rating CHECK (((rating >= 0) AND (rating <= 10))),
    CONSTRAINT check_ins_review_check CHECK (((length(review) >= 1) AND (length(review) <= 1024)))
);


--
-- Name: check_ins_id_seq; Type: SEQUENCE; Schema: tasted_public; Owner: -
--

CREATE SEQUENCE tasted_public.check_ins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_ins_id_seq; Type: SEQUENCE OWNED BY; Schema: tasted_public; Owner: -
--

ALTER SEQUENCE tasted_public.check_ins_id_seq OWNED BY tasted_public.check_ins.id;


--
-- Name: companies; Type: TABLE; Schema: tasted_public; Owner: -
--

CREATE TABLE tasted_public.companies (
    id integer NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    name tasted_public.medium_text
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: tasted_public; Owner: -
--

CREATE SEQUENCE tasted_public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: tasted_public; Owner: -
--

ALTER SEQUENCE tasted_public.companies_id_seq OWNED BY tasted_public.companies.id;


--
-- Name: products; Type: TABLE; Schema: tasted_public; Owner: -
--

CREATE TABLE tasted_public.products (
    id integer NOT NULL,
    name tasted_public.medium_text,
    brand_id integer NOT NULL,
    description tasted_public.long_text,
    type_id integer NOT NULL,
    is_verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    manufacturer_id integer
);


--
-- Name: products_id_seq; Type: SEQUENCE; Schema: tasted_public; Owner: -
--

CREATE SEQUENCE tasted_public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: tasted_public; Owner: -
--

ALTER SEQUENCE tasted_public.products_id_seq OWNED BY tasted_public.products.id;


--
-- Name: types; Type: TABLE; Schema: tasted_public; Owner: -
--

CREATE TABLE tasted_public.types (
    id integer NOT NULL,
    name text NOT NULL,
    category text NOT NULL
);


--
-- Name: types_id_seq; Type: SEQUENCE; Schema: tasted_public; Owner: -
--

CREATE SEQUENCE tasted_public.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: tasted_public; Owner: -
--

ALTER SEQUENCE tasted_public.types_id_seq OWNED BY tasted_public.types.id;


--
-- Name: brands id; Type: DEFAULT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.brands ALTER COLUMN id SET DEFAULT nextval('tasted_public.brands_id_seq'::regclass);


--
-- Name: check_ins id; Type: DEFAULT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.check_ins ALTER COLUMN id SET DEFAULT nextval('tasted_public.check_ins_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.companies ALTER COLUMN id SET DEFAULT nextval('tasted_public.companies_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products ALTER COLUMN id SET DEFAULT nextval('tasted_public.products_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.types ALTER COLUMN id SET DEFAULT nextval('tasted_public.types_id_seq'::regclass);


--
-- Name: user_secrets user_secrets_pkey; Type: CONSTRAINT; Schema: tasted_private; Owner: -
--

ALTER TABLE ONLY tasted_private.user_secrets
    ADD CONSTRAINT user_secrets_pkey PRIMARY KEY (user_id);


--
-- Name: brands brands_company_id_name_key; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.brands
    ADD CONSTRAINT brands_company_id_name_key UNIQUE (company_id, name);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (name);


--
-- Name: check_ins check_ins_pkey; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.check_ins
    ADD CONSTRAINT check_ins_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: companies company_name_key; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.companies
    ADD CONSTRAINT company_name_key UNIQUE (name);


--
-- Name: products products_name_brand_id_type_id_key; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products
    ADD CONSTRAINT products_name_brand_id_type_id_key UNIQUE (name, brand_id, type_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: types types_name_category_key; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.types
    ADD CONSTRAINT types_name_category_key UNIQUE (name, category);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: products _100_timestamps; Type: TRIGGER; Schema: tasted_public; Owner: -
--

CREATE TRIGGER _100_timestamps BEFORE INSERT OR UPDATE ON tasted_public.products FOR EACH ROW EXECUTE FUNCTION tasted_private.tg__timestamps();


--
-- Name: user_secrets user_secrets_user_id_fkey; Type: FK CONSTRAINT; Schema: tasted_private; Owner: -
--

ALTER TABLE ONLY tasted_private.user_secrets
    ADD CONSTRAINT user_secrets_user_id_fkey FOREIGN KEY (user_id) REFERENCES tasted_public.users(id) ON DELETE CASCADE;


--
-- Name: brands brands_company_id_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.brands
    ADD CONSTRAINT brands_company_id_fkey FOREIGN KEY (company_id) REFERENCES tasted_public.companies(id) ON DELETE CASCADE;


--
-- Name: brands brands_created_by_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.brands
    ADD CONSTRAINT brands_created_by_fkey FOREIGN KEY (created_by) REFERENCES tasted_public.users(id) ON DELETE SET NULL;


--
-- Name: brands brands_updated_by_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.brands
    ADD CONSTRAINT brands_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES tasted_public.users(id) ON DELETE SET NULL;


--
-- Name: check_ins check_ins_author_id_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.check_ins
    ADD CONSTRAINT check_ins_author_id_fkey FOREIGN KEY (author_id) REFERENCES tasted_public.users(id) ON DELETE CASCADE;


--
-- Name: check_ins check_ins_product_id_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.check_ins
    ADD CONSTRAINT check_ins_product_id_fkey FOREIGN KEY (product_id) REFERENCES tasted_public.products(id) ON DELETE CASCADE;


--
-- Name: companies companies_created_by_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.companies
    ADD CONSTRAINT companies_created_by_fkey FOREIGN KEY (created_by) REFERENCES tasted_public.users(id) ON DELETE SET NULL;


--
-- Name: products products_brand_id_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products
    ADD CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES tasted_public.brands(id) ON DELETE CASCADE;


--
-- Name: products products_created_by_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products
    ADD CONSTRAINT products_created_by_fkey FOREIGN KEY (created_by) REFERENCES tasted_public.users(id) ON DELETE SET NULL;


--
-- Name: products products_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products
    ADD CONSTRAINT products_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES tasted_public.companies(id) ON DELETE CASCADE;


--
-- Name: products products_type_id_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products
    ADD CONSTRAINT products_type_id_fkey FOREIGN KEY (type_id) REFERENCES tasted_public.types(id) ON DELETE CASCADE;


--
-- Name: products products_updated_by_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.products
    ADD CONSTRAINT products_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES tasted_public.users(id) ON DELETE SET NULL;


--
-- Name: types types_category_fkey; Type: FK CONSTRAINT; Schema: tasted_public; Owner: -
--

ALTER TABLE ONLY tasted_public.types
    ADD CONSTRAINT types_category_fkey FOREIGN KEY (category) REFERENCES tasted_public.categories(name) ON DELETE CASCADE;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM postgres;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO tasted;
GRANT USAGE ON SCHEMA public TO tasted_visitor;


--
-- Name: SCHEMA tasted_hidden; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA tasted_hidden TO tasted_visitor;


--
-- Name: SCHEMA tasted_public; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA tasted_public TO tasted_visitor;


--
-- Name: FUNCTION assert_valid_password(new_password text); Type: ACL; Schema: tasted_private; Owner: -
--

REVOKE ALL ON FUNCTION tasted_private.assert_valid_password(new_password text) FROM PUBLIC;


--
-- Name: PROCEDURE migrate_seed(); Type: ACL; Schema: tasted_private; Owner: -
--

REVOKE ALL ON PROCEDURE tasted_private.migrate_seed() FROM PUBLIC;


--
-- Name: FUNCTION really_create_user(username public.citext, password text); Type: ACL; Schema: tasted_private; Owner: -
--

REVOKE ALL ON FUNCTION tasted_private.really_create_user(username public.citext, password text) FROM PUBLIC;


--
-- Name: FUNCTION tg__timestamps(); Type: ACL; Schema: tasted_private; Owner: -
--

REVOKE ALL ON FUNCTION tasted_private.tg__timestamps() FROM PUBLIC;


--
-- Name: FUNCTION login(username public.citext, password text); Type: ACL; Schema: tasted_public; Owner: -
--

REVOKE ALL ON FUNCTION tasted_public.login(username public.citext, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION tasted_public.login(username public.citext, password text) TO tasted_visitor;


--
-- Name: FUNCTION register(username public.citext, password text); Type: ACL; Schema: tasted_public; Owner: -
--

REVOKE ALL ON FUNCTION tasted_public.register(username public.citext, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION tasted_public.register(username public.citext, password text) TO tasted_visitor;


--
-- Name: SEQUENCE brands_id_seq; Type: ACL; Schema: tasted_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE tasted_public.brands_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE check_ins_id_seq; Type: ACL; Schema: tasted_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE tasted_public.check_ins_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE companies_id_seq; Type: ACL; Schema: tasted_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE tasted_public.companies_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE products_id_seq; Type: ACL; Schema: tasted_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE tasted_public.products_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE types_id_seq; Type: ACL; Schema: tasted_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE tasted_public.types_id_seq TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA public GRANT ALL ON FUNCTIONS  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: tasted_hidden; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA tasted_hidden GRANT SELECT,USAGE ON SEQUENCES  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: tasted_hidden; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA tasted_hidden GRANT ALL ON FUNCTIONS  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: tasted_public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA tasted_public GRANT SELECT,USAGE ON SEQUENCES  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: tasted_public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA tasted_public GRANT ALL ON FUNCTIONS  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted REVOKE ALL ON FUNCTIONS  FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

