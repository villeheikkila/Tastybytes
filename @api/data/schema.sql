--
-- PostgreSQL database dump
--

-- Dumped from database version 14.0
-- Dumped by pg_dump version 14.0

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
-- Name: app_hidden; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app_hidden;


--
-- Name: app_private; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app_private;


--
-- Name: app_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA app_public;


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
-- Name: role; Type: TYPE; Schema: app_private; Owner: -
--

CREATE TYPE app_private.role AS ENUM (
    'user',
    'moderator',
    'admin'
);


--
-- Name: friend_status; Type: TYPE; Schema: app_public; Owner: -
--

CREATE TYPE app_public.friend_status AS ENUM (
    'accepted',
    'pending',
    'blocked'
);


--
-- Name: long_text; Type: DOMAIN; Schema: app_public; Owner: -
--

CREATE DOMAIN app_public.long_text AS text
	CONSTRAINT long_text_check CHECK (((length(VALUE) >= 0) AND (length(VALUE) <= 1024)));


--
-- Name: name; Type: DOMAIN; Schema: app_public; Owner: -
--

CREATE DOMAIN app_public.name AS text
	CONSTRAINT name_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 56)));


--
-- Name: rating; Type: DOMAIN; Schema: app_public; Owner: -
--

CREATE DOMAIN app_public.rating AS integer
	CONSTRAINT rating_check CHECK (((VALUE >= 0) AND (VALUE <= 10)));


--
-- Name: short_text; Type: DOMAIN; Schema: app_public; Owner: -
--

CREATE DOMAIN app_public.short_text AS text
	CONSTRAINT short_text_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 64)));


--
-- Name: assert_valid_password(text); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.assert_valid_password(new_password text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  -- TODO: add better assertions!
  if length(new_password) < 8 then
    raise exception 'Password is too weak' using errcode = 'WEAKP';
  end if;
end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: users; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username public.citext NOT NULL,
    avatar_url text,
    is_admin boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    first_name text,
    last_name text,
    location text,
    country text,
    CONSTRAINT users_avatar_url_check CHECK ((avatar_url ~ '^https?://[^/]+'::text)),
    CONSTRAINT users_country_check CHECK (((length(country) >= 2) AND (length(country) <= 56))),
    CONSTRAINT users_first_name_check CHECK (((length(first_name) >= 2) AND (length(first_name) <= 56))),
    CONSTRAINT users_last_name_check CHECK (((length(last_name) >= 2) AND (length(last_name) <= 56))),
    CONSTRAINT users_location_check CHECK (((length(location) >= 2) AND (length(location) <= 56))),
    CONSTRAINT users_username_check CHECK (((length((username)::text) >= 2) AND (length((username)::text) <= 24) AND (username OPERATOR(public.~) '^[a-zA-Z]([_]?[a-zA-Z0-9])+$'::public.citext)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.users IS 'A user who can log in to the application.';


--
-- Name: COLUMN users.id; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.users.id IS 'Unique identifier for the user.';


--
-- Name: COLUMN users.username; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.users.username IS 'Public-facing username (or ''handle'') of the user.';


--
-- Name: COLUMN users.avatar_url; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.users.avatar_url IS 'Optional avatar URL.';


--
-- Name: COLUMN users.is_admin; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.users.is_admin IS 'If true, the user has elevated privileges.';


--
-- Name: link_or_register_user(uuid, character varying, character varying, json, json); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.link_or_register_user(f_user_id uuid, f_service character varying, f_identifier character varying, f_profile json, f_auth_details json) RETURNS app_public.users
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_matched_user_id uuid;
  v_matched_authentication_id uuid;
  v_email citext;
  v_first_name text;
  v_last_name text;
  v_avatar_url text;
  v_user app_public.users;
  v_user_email app_public.user_emails;
begin
  -- See if a user account already matches these details
  select id, user_id
    into v_matched_authentication_id, v_matched_user_id
    from app_public.user_authentications
    where service = f_service
    and identifier = f_identifier
    limit 1;

  if v_matched_user_id is not null and f_user_id is not null and v_matched_user_id <> f_user_id then
    raise exception 'A different user already has this account linked.' using errcode = 'TAKEN';
  end if;

  v_email = f_profile ->> 'email';
  v_first_name := f_profile ->> 'first_name';
  v_last_name := f_profile ->> 'last_name';
  v_avatar_url := f_profile ->> 'avatar_url';

  if v_matched_authentication_id is null then
    if f_user_id is not null then
      -- Link new account to logged in user account
      insert into app_public.user_authentications (user_id, service, identifier, details) values
        (f_user_id, f_service, f_identifier, f_profile) returning id, user_id into v_matched_authentication_id, v_matched_user_id;
      insert into app_private.user_authentication_secrets (user_authentication_id, details) values
        (v_matched_authentication_id, f_auth_details);
      perform graphile_worker.add_job(
        'user__audit',
        json_build_object(
          'type', 'linked_account',
          'user_id', f_user_id,
          'extra1', f_service,
          'extra2', f_identifier,
          'current_user_id', app_public.current_user_id()
        ));
    elsif v_email is not null then
      -- See if the email is registered
      select * into v_user_email from app_public.user_emails where email = v_email and is_verified is true;
      if v_user_email is not null then
        -- User exists!
        insert into app_public.user_authentications (user_id, service, identifier, details) values
          (v_user_email.user_id, f_service, f_identifier, f_profile) returning id, user_id into v_matched_authentication_id, v_matched_user_id;
        insert into app_private.user_authentication_secrets (user_authentication_id, details) values
          (v_matched_authentication_id, f_auth_details);
        perform graphile_worker.add_job(
          'user__audit',
          json_build_object(
            'type', 'linked_account',
            'user_id', f_user_id,
            'extra1', f_service,
            'extra2', f_identifier,
            'current_user_id', app_public.current_user_id()
          ));
      end if;
    end if;
  end if;
  if v_matched_user_id is null and f_user_id is null and v_matched_authentication_id is null then
    -- Create and return a new user account
    return app_private.register_user(f_service, f_identifier, f_profile, f_auth_details, true);
  else
    if v_matched_authentication_id is not null then
      update app_public.user_authentications
        set details = f_profile
        where id = v_matched_authentication_id;
      update app_private.user_authentication_secrets
        set details = f_auth_details
        where user_authentication_id = v_matched_authentication_id;
      update app_public.users
        set
          first_name = coalesce(users.name, v_first_name),
          last_name = coalesce(users.name, v_last_name),
          avatar_url = coalesce(users.avatar_url, v_avatar_url)
        where id = v_matched_user_id
        returning  * into v_user;
      return v_user;
    else
      -- v_matched_authentication_id is null
      -- -> v_matched_user_id is null (they're paired)
      -- -> f_user_id is not null (because the if clause above)
      -- -> v_matched_authentication_id is not null (because of the separate if block above creating a user_authentications)
      -- -> contradiction.
      raise exception 'This should not occur';
    end if;
  end if;
end;
$$;


--
-- Name: FUNCTION link_or_register_user(f_user_id uuid, f_service character varying, f_identifier character varying, f_profile json, f_auth_details json); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.link_or_register_user(f_user_id uuid, f_service character varying, f_identifier character varying, f_profile json, f_auth_details json) IS 'If you''re logged in, this will link an additional OAuth login to your account if necessary. If you''re logged out it may find if an account already exists (based on OAuth details or email address) and return that, or create a new user account if necessary.';


--
-- Name: sessions; Type: TABLE; Schema: app_private; Owner: -
--

CREATE TABLE app_private.sessions (
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_active timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: login(public.citext, text); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.login(username public.citext, password text) RETURNS app_private.sessions
    LANGUAGE plpgsql STRICT
    AS $$
declare
  v_user app_public.users;
  v_user_secret app_private.user_secrets;
  v_login_attempt_window_duration interval = interval '5 minutes';
  v_session app_private.sessions;
begin
  if username like '%@%' then
    -- It's an email
    select users.* into v_user
    from app_public.users
    inner join app_public.user_emails
    on (user_emails.user_id = users.id)
    where user_emails.email = login.username
    order by
      user_emails.is_verified desc, -- Prefer verified email
      user_emails.created_at asc -- Failing that, prefer the first registered (unverified users _should_ verify before logging in)
    limit 1;
  else
    -- It's a username
    select users.* into v_user
    from app_public.users
    where users.username = login.username;
  end if;

  if not (v_user is null) then
    -- Load their secrets
    select * into v_user_secret from app_private.user_secrets
    where user_secrets.user_id = v_user.id;

    -- Have there been too many login attempts?
    if (
      v_user_secret.first_failed_password_attempt is not null
    and
      v_user_secret.first_failed_password_attempt > NOW() - v_login_attempt_window_duration
    and
      v_user_secret.failed_password_attempts >= 3
    ) then
      raise exception 'User account locked - too many login attempts. Try again after 5 minutes.' using errcode = 'LOCKD';
    end if;

    -- Not too many login attempts, let's check the password.
    -- NOTE: `password_hash` could be null, this is fine since `NULL = NULL` is null, and null is falsy.
    if v_user_secret.password_hash = crypt(password, v_user_secret.password_hash) then
      -- Excellent - they're logged in! Let's reset the attempt tracking
      update app_private.user_secrets
      set failed_password_attempts = 0, first_failed_password_attempt = null, last_login_at = now()
      where user_id = v_user.id;
      -- Create a session for the user
      insert into app_private.sessions (user_id) values (v_user.id) returning * into v_session;
      -- And finally return the session
      return v_session;
    else
      -- Wrong password, bump all the attempt tracking figures
      update app_private.user_secrets
      set
        failed_password_attempts = (case when first_failed_password_attempt is null or first_failed_password_attempt < now() - v_login_attempt_window_duration then 1 else failed_password_attempts + 1 end),
        first_failed_password_attempt = (case when first_failed_password_attempt is null or first_failed_password_attempt < now() - v_login_attempt_window_duration then now() else first_failed_password_attempt end)
      where user_id = v_user.id;
      return null; -- Must not throw otherwise transaction will be aborted and attempts won't be recorded
    end if;
  else
    -- No user with that email/username was found
    return null;
  end if;
end;
$$;


--
-- Name: FUNCTION login(username public.citext, password text); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.login(username public.citext, password text) IS 'Returns a user that matches the username/password combo, or null on failure.';


--
-- Name: migrate_seed(); Type: PROCEDURE; Schema: app_private; Owner: -
--

CREATE PROCEDURE app_private.migrate_seed()
    LANGUAGE sql
    AS $$
INSERT INTO app_public.companies (name)
SELECT DISTINCT company AS name
FROM app_private.transferable_check_ins ON CONFLICT DO NOTHING;
INSERT INTO app_public.categories (name)
SELECT DISTINCT category AS name
FROM app_private.transferable_check_ins ON CONFLICT DO NOTHING;
WITH types AS (
  SELECT DISTINCT category,
    style AS name
  FROM app_private.transferable_check_ins
)
INSERT INTO app_public.types (name, category)
SELECT name,
  category
FROM types ON CONFLICT DO NOTHING;
WITH brands AS (
  SELECT DISTINCT brand,
    company
  FROM app_private.transferable_check_ins
)
INSERT INTO app_public.brands (name, company_id)
SELECT b.brand as name,
  c.id as company_id
FROM brands b
  LEFT JOIN app_public.companies c ON b.company = c.name ON CONFLICT DO NOTHING;
WITH items AS (
  SELECT b.id as brand_id,
    p.flavor,
    c.id AS manufacturer_id,
    t.id AS type_id
  FROM app_private.transferable_check_ins p
    LEFT JOIN app_public.companies c ON p.company = c.name
    LEFT JOIN app_public.types t ON p.style = t.name
    AND p.category = t.category
    LEFT JOIN app_public.brands b ON p.brand = b.name
    AND b.company_id = c.id
)
INSERT INTO app_public.items (flavor, brand_id, manufacturer_id, type_id)
SELECT flavor,
  brand_id,
  manufacturer_id,
  type_id
FROM items ON CONFLICT DO NOTHING;
WITH check_ins AS (
  SELECT CASE
      WHEN LENGTH(p.rating) > 0 THEN (
        REPLACE(p.rating, ',', '.')::DECIMAL * 2
      )::INTEGER
      ELSE NULL
    END AS rating,
    i.id AS item_id
  FROM app_private.transferable_check_ins p
    LEFT JOIN app_public.companies c ON p.company = c.name
    LEFT JOIN app_public.brands b ON b.company_id = c.id
    AND b.name = p.brand
    LEFT JOIN app_public.categories k ON k.name = p.category
    LEFT JOIN app_public.types t ON t.category = k.name
    AND p.style = t.name
    LEFT JOIN app_public.items i ON i.manufacturer_id = c.id
    AND b.id = i.brand_id
    AND i.flavor = p.flavor
    AND i.type_id = t.id
)
INSERT INTO app_public.check_ins (rating, item_id, author_id)
SELECT rating,
  i.item_id AS item_id,
  (
    SELECT id
    FROM app_public.users
    WHERE username = 'villeheikkila'
  ) AS author_id
FROM check_ins i $$;


--
-- Name: really_create_user(public.citext, text, boolean, text, text, text); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.really_create_user(username public.citext, email text, email_is_verified boolean, name text, avatar_url text, password text DEFAULT NULL::text) RETURNS app_public.users
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user     app_public.users;
  v_username citext = username;
begin
  if password is not null then
    perform app_private.assert_valid_password(password);
  end if;
  if email is null then
    raise exception 'email is required' using errcode = 'modat';
  end if;

  insert into app_public.users (username, name, avatar_url)
  values (v_username, name, avatar_url)
  returning * into v_user;

  insert into app_public.user_emails (user_id, email, is_verified, is_primary)
  values (v_user.id, email, email_is_verified, email_is_verified);

  insert into app_public.user_settings (id)
  values (v_user.id);

  if password is not null then
    update app_private.user_secrets
    set password_hash = crypt(password, gen_salt('bf'))
    where user_id = v_user.id;
  end if;

  select * into v_user from app_public.users where id = v_user.id;

  return v_user;
end;
$$;


--
-- Name: FUNCTION really_create_user(username public.citext, email text, email_is_verified boolean, name text, avatar_url text, password text); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.really_create_user(username public.citext, email text, email_is_verified boolean, name text, avatar_url text, password text) IS 'Creates a user account. All arguments are optional, it trusts the calling method to perform sanitisation.';


--
-- Name: really_create_user(public.citext, text, boolean, text, text, text, text); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.really_create_user(username public.citext, email text, email_is_verified boolean, first_name text, last_name text, avatar_url text, password text DEFAULT NULL::text) RETURNS app_public.users
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user app_public.users;
  v_username citext = username;
begin
  if password is not null then
    perform app_private.assert_valid_password(password);
  end if;
  if email is null then
    raise exception 'Email is required' using errcode = 'MODAT';
  end if;

  -- Insert the new user
  insert into app_public.users (username, first_name, last_name, avatar_url) values
    (v_username, first_name, last_name, avatar_url)
    returning * into v_user;

	-- Add the user's email
  insert into app_public.user_emails (user_id, email, is_verified, is_primary)
  values (v_user.id, email, email_is_verified, email_is_verified);

  -- Store the password
  if password is not null then
    update app_private.user_secrets
    set password_hash = crypt(password, gen_salt('bf'))
    where user_id = v_user.id;
  end if;

  -- Refresh the user
  select * into v_user from app_public.users where id = v_user.id;

  return v_user;
end;
$$;


--
-- Name: register_user(character varying, character varying, json, json, boolean); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.register_user(f_service character varying, f_identifier character varying, f_profile json, f_auth_details json, f_email_is_verified boolean DEFAULT false) RETURNS app_public.users
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user app_public.users;
  v_email citext;
  v_first_name text;
  v_last_name text;
  v_username citext;
  v_avatar_url text;
  v_user_authentication_id uuid;
begin
  -- Extract data from the user’s OAuth profile data.
  v_email := f_profile ->> 'email';
  v_first_name := f_profile ->> 'first_name';
  v_last_name := f_profile ->> 'last_name';
  v_username := f_profile ->> 'username';
  v_avatar_url := f_profile ->> 'avatar_url';

  -- Sanitise the username, and make it unique if necessary.
  if v_username is null then
    v_username = coalesce(concat(v_first_name, '-', v_last_name), 'user');
  end if;
  v_username = regexp_replace(v_username, '^[^a-z]+', '', 'gi');
  v_username = regexp_replace(v_username, '[^a-z0-9]+', '_', 'gi');
  if v_username is null or length(v_username) < 3 then
    v_username = 'user';
  end if;
  select (
    case
    when i = 0 then v_username
    else v_username || i::text
    end
  ) into v_username from generate_series(0, 1000) i
  where not exists(
    select 1
    from app_public.users
    where users.username = (
      case
      when i = 0 then v_username
      else v_username || i::text
      end
    )
  )
  limit 1;

  -- Create the user account
  v_user = app_private.really_create_user(
    username => v_username,
    email => v_email,
    email_is_verified => f_email_is_verified,
    first_name => v_first_name,
    last_name => v_last_name,
    avatar_url => v_avatar_url
  );

  -- Insert the user’s private account data (e.g. OAuth tokens)
  insert into app_public.user_authentications (user_id, service, identifier, details) values
    (v_user.id, f_service, f_identifier, f_profile) returning id into v_user_authentication_id;
  insert into app_private.user_authentication_secrets (user_authentication_id, details) values
    (v_user_authentication_id, f_auth_details);

  return v_user;
end;
$$;


--
-- Name: FUNCTION register_user(f_service character varying, f_identifier character varying, f_profile json, f_auth_details json, f_email_is_verified boolean); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.register_user(f_service character varying, f_identifier character varying, f_profile json, f_auth_details json, f_email_is_verified boolean) IS 'Used to register a user from information gleaned from OAuth. Primarily used by link_or_register_user';


--
-- Name: reset_password(uuid, text, text); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.reset_password(user_id uuid, reset_token text, new_password text) RETURNS boolean
    LANGUAGE plpgsql STRICT
    AS $$
declare
  v_user app_public.users;
  v_user_secret app_private.user_secrets;
  v_token_max_duration interval = interval '3 days';
begin
  select users.* into v_user
  from app_public.users
  where id = user_id;

  if not (v_user is null) then
    -- Load their secrets
    select * into v_user_secret from app_private.user_secrets
    where user_secrets.user_id = v_user.id;

    -- Have there been too many reset attempts?
    if (
      v_user_secret.first_failed_reset_password_attempt is not null
    and
      v_user_secret.first_failed_reset_password_attempt > NOW() - v_token_max_duration
    and
      v_user_secret.failed_reset_password_attempts >= 20
    ) then
      raise exception 'Password reset locked - too many reset attempts' using errcode = 'LOCKD';
    end if;

    -- Not too many reset attempts, let's check the token
    if v_user_secret.reset_password_token = reset_token then
      -- Excellent - they're legit
      perform app_private.assert_valid_password(new_password);
      -- Let's reset the password as requested
      update app_private.user_secrets
      set
        password_hash = crypt(new_password, gen_salt('bf')),
        failed_password_attempts = 0,
        first_failed_password_attempt = null,
        reset_password_token = null,
        reset_password_token_generated = null,
        failed_reset_password_attempts = 0,
        first_failed_reset_password_attempt = null
      where user_secrets.user_id = v_user.id;
      perform graphile_worker.add_job(
        'user__audit',
        json_build_object(
          'type', 'reset_password',
          'user_id', v_user.id,
          'current_user_id', app_public.current_user_id()
        ));
      return true;
    else
      -- Wrong token, bump all the attempt tracking figures
      update app_private.user_secrets
      set
        failed_reset_password_attempts = (case when first_failed_reset_password_attempt is null or first_failed_reset_password_attempt < now() - v_token_max_duration then 1 else failed_reset_password_attempts + 1 end),
        first_failed_reset_password_attempt = (case when first_failed_reset_password_attempt is null or first_failed_reset_password_attempt < now() - v_token_max_duration then now() else first_failed_reset_password_attempt end)
      where user_secrets.user_id = v_user.id;
      return null;
    end if;
  else
    -- No user with that id was found
    return null;
  end if;
end;
$$;


--
-- Name: tg__add_audit_job(); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.tg__add_audit_job() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $_$
declare
  v_user_id uuid;
  v_type text = TG_ARGV[0];
  v_user_id_attribute text = TG_ARGV[1];
  v_extra_attribute1 text = TG_ARGV[2];
  v_extra_attribute2 text = TG_ARGV[3];
  v_extra_attribute3 text = TG_ARGV[4];
  v_extra1 text;
  v_extra2 text;
  v_extra3 text;
begin
  if v_user_id_attribute is null then
    raise exception 'Invalid tg__add_audit_job call';
  end if;

  execute 'select ($1.' || quote_ident(v_user_id_attribute) || ')::uuid'
    using (case when TG_OP = 'INSERT' then NEW else OLD end)
    into v_user_id;

  if v_extra_attribute1 is not null then
    execute 'select ($1.' || quote_ident(v_extra_attribute1) || ')::text'
      using (case when TG_OP = 'DELETE' then OLD else NEW end)
      into v_extra1;
  end if;
  if v_extra_attribute2 is not null then
    execute 'select ($1.' || quote_ident(v_extra_attribute2) || ')::text'
      using (case when TG_OP = 'DELETE' then OLD else NEW end)
      into v_extra2;
  end if;
  if v_extra_attribute3 is not null then
    execute 'select ($1.' || quote_ident(v_extra_attribute3) || ')::text'
      using (case when TG_OP = 'DELETE' then OLD else NEW end)
      into v_extra3;
  end if;

  if v_user_id is not null then
    perform graphile_worker.add_job(
      'user__audit',
      json_build_object(
        'type', v_type,
        'user_id', v_user_id,
        'extra1', v_extra1,
        'extra2', v_extra2,
        'extra3', v_extra3,
        'current_user_id', app_public.current_user_id(),
        'schema', TG_TABLE_SCHEMA,
        'table', TG_TABLE_NAME
      ));
  end if;

  return NEW;
end;
$_$;


--
-- Name: FUNCTION tg__add_audit_job(); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.tg__add_audit_job() IS 'For notifying a user that an auditable action has taken place. Call with audit event name, user ID attribute name, and optionally another value to be included (e.g. the PK of the table, or some other relevant information). e.g. `tg__add_audit_job(''added_email'', ''user_id'', ''email'')`';


--
-- Name: tg__add_job(); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.tg__add_job() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  perform graphile_worker.add_job(tg_argv[0], json_build_object('id', NEW.id));
  return NEW;
end;
$$;


--
-- Name: FUNCTION tg__add_job(); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.tg__add_job() IS 'Useful shortcut to create a job on insert/update. Pass the task name as the first trigger argument, and optionally the queue name as the second argument. The record id will automatically be available on the JSON payload.';


--
-- Name: tg__created(); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.tg__created() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_cata'
    AS $$
begin
  new.created_by = app_public.current_user_id();
  new.is_verified = app_public.current_user_is_privileged ();
  return new;
end;
$$;


--
-- Name: tg__timestamps(); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.tg__timestamps() RETURNS trigger
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
-- Name: FUNCTION tg__timestamps(); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.tg__timestamps() IS 'This trigger should be called on all tables with created_at, updated_at - it ensures that they cannot be manipulated and that updated_at will always be larger than the previous updated_at.';


--
-- Name: tg_user_email_secrets__insert_with_user_email(); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.tg_user_email_secrets__insert_with_user_email() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_verification_token text;
begin
  if NEW.is_verified is false then
    v_verification_token = encode(gen_random_bytes(7), 'hex');
  end if;
  insert into app_private.user_email_secrets(user_email_id, verification_token) values(NEW.id, v_verification_token);
  return NEW;
end;
$$;


--
-- Name: FUNCTION tg_user_email_secrets__insert_with_user_email(); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.tg_user_email_secrets__insert_with_user_email() IS 'Ensures that every user_email record has an associated user_email_secret record.';


--
-- Name: tg_user_secrets__insert_with_user(); Type: FUNCTION; Schema: app_private; Owner: -
--

CREATE FUNCTION app_private.tg_user_secrets__insert_with_user() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  insert into app_private.user_secrets(user_id) values(NEW.id);
  return NEW;
end;
$$;


--
-- Name: FUNCTION tg_user_secrets__insert_with_user(); Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON FUNCTION app_private.tg_user_secrets__insert_with_user() IS 'Ensures that every user record has an associated user_secret record.';


--
-- Name: accept_friend_request(uuid); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.accept_friend_request(user_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_current_status  app_public.friends;
  v_current_user    uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to accept a friendship relation' using errcode = 'LOGIN';
  end if;

  select *
  from app_public.friends
  where (user_id_1 = v_current_user and user_id_2 = user_id)
     or (user_id_1 = user_id and user_id_2 = v_current_user)
  into v_current_status;

  if exists(select 1 from v_current_status) = false then
    raise exception 'No such friend request exists' using errcode = 'INVAL';
  elseif (select status from v_current_status) = 'accepted' then
    raise exception 'You are already friends' using errcode = 'INVAL';
  end if;

  update app_public.friends set (status) = ('accepted') where user_id = (select user_id_1 from v_current_status) and user_id_2 = (select user_id_2 from v_current_status);
end;
$$;


--
-- Name: change_password(text, text); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.change_password(old_password text, new_password text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user app_public.users;
  v_user_secret app_private.user_secrets;
begin
  select users.* into v_user
  from app_public.users
  where id = app_public.current_user_id();

  if not (v_user is null) then
    -- Load their secrets
    select * into v_user_secret from app_private.user_secrets
    where user_secrets.user_id = v_user.id;

    if v_user_secret.password_hash = crypt(old_password, v_user_secret.password_hash) then
      perform app_private.assert_valid_password(new_password);
      -- Reset the password as requested
      update app_private.user_secrets
      set
        password_hash = crypt(new_password, gen_salt('bf'))
      where user_secrets.user_id = v_user.id;
      perform graphile_worker.add_job(
        'user__audit',
        json_build_object(
          'type', 'change_password',
          'user_id', v_user.id,
          'current_user_id', app_public.current_user_id()
        ));
      return true;
    else
      raise exception 'Incorrect password' using errcode = 'CREDS';
    end if;
  else
    raise exception 'You must log in to change your password' using errcode = 'LOGIN';
  end if;
end;
$$;


--
-- Name: FUNCTION change_password(old_password text, new_password text); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.change_password(old_password text, new_password text) IS 'Enter your old password and a new password to change your password.';


--
-- Name: checkinstatistics(app_public.users); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.checkinstatistics(u app_public.users) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  SELECT 'dasda';
$$;


--
-- Name: confirm_account_deletion(text); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.confirm_account_deletion(token text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user_secret app_private.user_secrets;
  v_token_max_duration interval = interval '3 days';
begin
  if app_public.current_user_id() is null then
    raise exception 'You must log in to delete your account' using errcode = 'LOGIN';
  end if;

  select * into v_user_secret
    from app_private.user_secrets
    where user_secrets.user_id = app_public.current_user_id();

  if v_user_secret is null then
    -- Success: they're already deleted
    return true;
  end if;

  -- Check the token
  if (
    -- token is still valid
    v_user_secret.delete_account_token_generated > now() - v_token_max_duration
  and
    -- token matches
    v_user_secret.delete_account_token = token
  ) then
    -- Token passes; delete their account :(
    delete from app_public.users where id = app_public.current_user_id();
    return true;
  end if;

  raise exception 'The supplied token was incorrect - perhaps you''re logged in to the wrong account, or the token has expired?' using errcode = 'DNIED';
end;
$$;


--
-- Name: FUNCTION confirm_account_deletion(token text); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.confirm_account_deletion(token text) IS 'If you''re certain you want to delete your account, use `requestAccountDeletion` to request an account deletion token, and then supply the token through this mutation to complete account deletion.';


--
-- Name: brands; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.brands (
    id integer NOT NULL,
    name app_public.short_text,
    company_id integer,
    is_verified boolean,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: create_brand(text, integer); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.create_brand(name text, company_id integer) RETURNS app_public.brands
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_verified boolean;
  v_brand app_public.brands;
  v_current_user uuid;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();

  if app_public.current_user_id() is null then
    raise exception 'You must log in to create a company' using errcode = 'LOGIN';
  end if;

  select is_admin into v_is_verified from app_public.users where id = v_current_user;

  insert into app_public.brands (name, company_id, is_verified, created_by) values (name, company_id, v_is_verified, v_current_user) returning * into v_brand;

  return v_brand;
end;
$$;


--
-- Name: check_ins; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.check_ins (
    id integer NOT NULL,
    rating integer,
    review text,
    item_id integer NOT NULL,
    author_id uuid NOT NULL,
    check_in_date date,
    location uuid,
    is_public boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    likes integer DEFAULT 0,
    CONSTRAINT check_ins_rating CHECK (((rating >= 0) AND (rating <= 10))),
    CONSTRAINT check_ins_review_check CHECK (((length(review) >= 1) AND (length(review) <= 1024)))
);


--
-- Name: TABLE check_ins; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.check_ins IS 'Check-in is a review given to an item';


--
-- Name: create_check_in(integer, text, integer, date); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.create_check_in(item_id integer, review text DEFAULT NULL::text, rating integer DEFAULT NULL::integer, check_in_date date DEFAULT NULL::date) RETURNS app_public.check_ins
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_public boolean;
  v_check_in app_public.check_ins;
  v_current_user uuid;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();
  if v_current_user is null then
    raise exception 'You must log in to create a check in' using errcode = 'LOGIN';
  end if;
  select is_public_check_ins into v_is_public from app_public.user_settings where id = v_current_user;

  insert into app_public.check_ins (item_id, rating, review, author_id, is_public) values (item_id, rating, review, v_current_user, v_is_public) returning * into v_check_in;

  return v_check_in;
end;
$$;


--
-- Name: check_in_comments; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.check_in_comments (
    id integer NOT NULL,
    check_in_id integer NOT NULL,
    created_by uuid NOT NULL,
    comment app_public.long_text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: create_check_in_comment(integer, text); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.create_check_in_comment(target_check_in_id integer, comment text) RETURNS app_public.check_in_comments
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_check_in_exists boolean;
  v_too_often       boolean;
  v_are_friends     boolean;
  v_current_user    uuid;
  v_check_in_id     integer;
  v_comment         app_public.check_in_comments;
begin
  v_current_user := app_public.current_user_id();
  v_check_in_id := target_check_in_id;

  if v_current_user is null then
    raise exception 'You must log in to add a comment' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.check_ins where id = v_check_in_id)
  into v_check_in_exists;

  if v_check_in_exists is false then
    raise exception 'No such check in exists' using errcode = 'INVAL';
  end if;

  select exists(select 1
                from app_public.check_in_comments c
                       left join app_public.check_ins ci on ci.id = c.check_in_id
                       left join app_public.friends f on ci.author_id = f.user_id_2
                where f.user_id_1 = v_current_user)
  into v_are_friends;

  if v_are_friends is false then
    raise exception 'You need to be friends to comment on a check in' using errcode = 'INVAL';
  end if;

  select exists(select 1
                from app_public.check_in_comments c
                where c.check_in_id = v_check_in_id
                  and c.created_at > NOW() - INTERVAL '1 minutes')
  into v_too_often;

  if v_too_often is true then
    raise exception 'You can only comment on same check in once in one minute' using errcode = 'LIMIT';
  end if;

  insert into app_public.check_in_comments (created_by, check_in_id, comment)
  values (v_current_user, check_in_id, comment)
  returning * into v_comment;

  return v_comment;
end;
$$;


--
-- Name: companies; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.companies (
    id integer NOT NULL,
    name text NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    CONSTRAINT companies_name_check CHECK (((length(name) >= 2) AND (length(name) <= 56)))
);


--
-- Name: create_company(text); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.create_company(company_name text) RETURNS app_public.companies
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_verified boolean;
  v_company app_public.companies;
  v_current_user uuid;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();

  if app_public.current_user_id() is null then
    raise exception 'You must log in to create a company' using errcode = 'LOGIN';
  end if;

  select is_admin into v_is_verified from app_public.users where id = v_current_user;

  insert into app_public.companies (name, is_verified, created_by) values (company_name, v_is_verified, v_current_user) returning * into v_company;

  return v_company;
end;
$$;


--
-- Name: FUNCTION create_company(company_name text); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.create_company(company_name text) IS 'Creates a new company. All arguments are required.';


--
-- Name: create_friend_request(uuid); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.create_friend_request(user_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_request_exists boolean;
  v_current_user   uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to create a friend request' using errcode = 'LOGIN';
  end if;

  select exists(select 1
                from app_public.friends
                where (user_id_1 = v_current_user and user_id_2 = user_id)
                   or (user_id_1 = user_id and user_id_2 = v_current_user))
  into v_request_exists;

  if v_request_exists is true then
    raise exception 'Friend request already exists' using errcode = 'INVAL';
  end if;

  insert into app_public.friends (user_id_1, user_id_2) values (v_current_user, user_id);
end;
$$;


--
-- Name: items; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.items (
    id integer NOT NULL,
    flavor text,
    description text,
    type_id integer NOT NULL,
    manufacturer_id integer NOT NULL,
    is_verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid,
    updated_by uuid,
    brand_id integer NOT NULL,
    CONSTRAINT items_description_check CHECK (((length(description) >= 2) AND (length(description) <= 512))),
    CONSTRAINT items_flavor_check CHECK (((length(flavor) >= 2) AND (length(flavor) <= 99)))
);


--
-- Name: TABLE items; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.items IS 'Item defines a product that can be rated';


--
-- Name: create_item(text, integer, integer, integer, text); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.create_item(flavor text, type_id integer, brand_id integer, manufacturer_id integer DEFAULT NULL::integer, description text DEFAULT NULL::text) RETURNS app_public.items
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_verified boolean;
  v_item app_public.items;
  v_current_user uuid;
begin
  if app_public.current_user_id() is null then
    raise exception 'You must log in to create an item' using errcode = 'LOGIN';
  end if;

  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();
  select is_admin into v_is_verified from app_public.users where id = v_current_user;

  insert into app_public.items (flavor, type_id, brand_id, manufacturer_id, description, is_verified, created_by, updated_by) values (flavor, type_id, brand_id, manufacturer_id, description, v_is_verified, v_current_user, v_current_user) returning * into v_item;

  return v_item;
end;
$$;


--
-- Name: current_session_id(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.current_session_id() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select nullif(pg_catalog.current_setting('jwt.claims.session_id', true), '')::uuid;
$$;


--
-- Name: FUNCTION current_session_id(); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.current_session_id() IS 'Handy method to get the current session ID.';


--
-- Name: current_user(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public."current_user"() RETURNS app_public.users
    LANGUAGE sql STABLE
    AS $$
  select users.* from app_public.users where id = app_public.current_user_id();
$$;


--
-- Name: FUNCTION "current_user"(); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public."current_user"() IS 'The currently logged in user (or null if not logged in).';


--
-- Name: current_user_friends(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.current_user_friends() RETURNS SETOF uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
  select user_id_1 as user_id from app_public.friends
    where user_id_2 = app_public.current_user_id() and status = 'accepted' union select user_id_2 as user_id from app_public.friends
    where user_id_1 = app_public.current_user_id() and status = 'accepted'
$$;


--
-- Name: current_user_id(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.current_user_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
  select user_id from app_private.sessions where uuid = app_public.current_session_id();
$$;


--
-- Name: FUNCTION current_user_id(); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.current_user_id() IS 'Handy method to get the current user ID for use in RLS policies, etc; in GraphQL, use `currentUser{id}` instead.';


--
-- Name: current_user_is_privileged(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.current_user_is_privileged() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
with current_user_roles as (
  select role
  from app_private.user_secrets where user_id = (select id from app_public.current_user())
)
select case when role = 'moderator' or role = 'admin' then true else false end as is_privileged
from current_user_roles;
$$;


--
-- Name: delete_friend(uuid); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.delete_friend(friend_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_is_friends   boolean;
  v_current_user uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to remove a friend request or friendship' using errcode = 'LOGIN';
  end if;

  select exists(select 1
                from app_public.friends
                where (user_id_1 = v_current_user and user_id_2 = friend_id)
                   or (user_id_2 = v_current_user and user_id_1 = friend_id))
  into v_is_friends;

  if v_is_friends is false then
    raise exception 'There is no such friend relation' using errcode = 'INVAL';
  end if;

  delete
  from app_public.friends
  where (user_id_1 = v_current_user and user_id_2 = friend_id)
     or (user_id_2 = v_current_user and user_id_1 = friend_id);
end;
$$;


--
-- Name: forgot_password(public.citext); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.forgot_password(email public.citext) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user_email app_public.user_emails;
  v_token text;
  v_token_min_duration_between_emails interval = interval '3 minutes';
  v_token_max_duration interval = interval '3 days';
  v_now timestamptz = clock_timestamp(); -- Function can be called multiple during transaction
  v_latest_attempt timestamptz;
begin
  -- Find the matching user_email:
  select user_emails.* into v_user_email
  from app_public.user_emails
  where user_emails.email = forgot_password.email
  order by is_verified desc, id desc;

  -- If there is no match:
  if v_user_email is null then
    -- This email doesn't exist in the system; trigger an email stating as much.

    -- We do not allow this email to be triggered more than once every 15
    -- minutes, so we need to track it:
    insert into app_private.unregistered_email_password_resets (email, latest_attempt)
      values (forgot_password.email, v_now)
      on conflict on constraint unregistered_email_pkey
      do update
        set latest_attempt = v_now, attempts = unregistered_email_password_resets.attempts + 1
        where unregistered_email_password_resets.latest_attempt < v_now - interval '15 minutes'
      returning latest_attempt into v_latest_attempt;

    if v_latest_attempt = v_now then
      perform graphile_worker.add_job(
        'user__forgot_password_unregistered_email',
        json_build_object('email', forgot_password.email::text)
      );
    end if;

    -- TODO: we should clear out the unregistered_email_password_resets table periodically.

    return;
  end if;

  -- There was a match.
  -- See if we've triggered a reset recently:
  if exists(
    select 1
    from app_private.user_email_secrets
    where user_email_id = v_user_email.id
    and password_reset_email_sent_at is not null
    and password_reset_email_sent_at > v_now - v_token_min_duration_between_emails
  ) then
    -- If so, take no action.
    return;
  end if;

  -- Fetch or generate reset token:
  update app_private.user_secrets
  set
    reset_password_token = (
      case
      when reset_password_token is null or reset_password_token_generated < v_now - v_token_max_duration
      then encode(gen_random_bytes(7), 'hex')
      else reset_password_token
      end
    ),
    reset_password_token_generated = (
      case
      when reset_password_token is null or reset_password_token_generated < v_now - v_token_max_duration
      then v_now
      else reset_password_token_generated
      end
    )
  where user_id = v_user_email.user_id
  returning reset_password_token into v_token;

  -- Don't allow spamming an email:
  update app_private.user_email_secrets
  set password_reset_email_sent_at = v_now
  where user_email_id = v_user_email.id;

  -- Trigger email send:
  perform graphile_worker.add_job(
    'user__forgot_password',
    json_build_object('id', v_user_email.user_id, 'email', v_user_email.email::text, 'token', v_token)
  );

end;
$$;


--
-- Name: FUNCTION forgot_password(email public.citext); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.forgot_password(email public.citext) IS 'If you''ve forgotten your password, give us one of your email addresses and we''ll send you a reset token. Note this only works if you have added an email address!';


--
-- Name: like_check_in(integer); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.like_check_in(check_in_id integer) RETURNS app_public.check_ins
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_check_in app_public.check_ins;
  v_current_user uuid;
  v_already_liked boolean;
begin
  select id into v_current_user from app_public.user_settings where id = app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to like a check in' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.check_in_likes where liked_by = v_current_user and id = check_in_id) into v_already_liked;

  if v_already_liked is true then
    update app_public.check_ins set likes = likes - 1 where id = check_in_id;
    delete from app_public.check_in_likes where id = check_in_id and liked_by = v_current_user;
    select * from app_public.check_ins where id = check_in_id;
  else
    update app_public.check_ins set likes = likes + 1 where id = check_in_id;
    insert into app_public.check_in_likes (id, liked_by) values (check_in_id, v_current_user) returning * into v_check_in;
  end if;

  return v_check_in;
end;
$$;


--
-- Name: logout(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.logout() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  -- Delete the session
  delete from app_private.sessions where uuid = app_public.current_session_id();
  -- Clear the identifier from the transaction
  perform set_config('jwt.claims.session_id', '', true);
end;
$$;


--
-- Name: user_emails; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.user_emails (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid DEFAULT app_public.current_user_id() NOT NULL,
    email public.citext NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_emails_email_check CHECK ((email OPERATOR(public.~) '[^@]+@[^@]+\.[^@]+'::public.citext)),
    CONSTRAINT user_emails_must_be_verified_to_be_primary CHECK (((is_primary IS FALSE) OR (is_verified IS TRUE)))
);


--
-- Name: TABLE user_emails; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.user_emails IS 'Information about a user''s email address.';


--
-- Name: COLUMN user_emails.email; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.user_emails.email IS 'The users email address, in `a@b.c` format.';


--
-- Name: COLUMN user_emails.is_verified; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.user_emails.is_verified IS 'True if the user has is_verified their email address (by clicking the link in the email we sent them, or logging in with a social login provider), false otherwise.';


--
-- Name: make_email_primary(uuid); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.make_email_primary(email_id uuid) RETURNS app_public.user_emails
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user_email app_public.user_emails;
begin
  select * into v_user_email from app_public.user_emails where id = email_id and user_id = app_public.current_user_id();
  if v_user_email is null then
    raise exception 'That''s not your email' using errcode = 'DNIED';
    return null;
  end if;
  if v_user_email.is_verified is false then
    raise exception 'You may not make an unverified email primary' using errcode = 'VRFY1';
  end if;
  update app_public.user_emails set is_primary = false where user_id = app_public.current_user_id() and is_primary is true and id <> email_id;
  update app_public.user_emails set is_primary = true where user_id = app_public.current_user_id() and is_primary is not true and id = email_id returning * into v_user_email;
  return v_user_email;
end;
$$;


--
-- Name: FUNCTION make_email_primary(email_id uuid); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.make_email_primary(email_id uuid) IS 'Your primary email is where we''ll notify of account events; other emails may be used for discovery or login. Use this when you''re changing your email address.';


--
-- Name: request_account_deletion(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.request_account_deletion() RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_user_email app_public.user_emails;
  v_token text;
  v_token_max_duration interval = interval '3 days';
begin
  if app_public.current_user_id() is null then
    raise exception 'You must log in to delete your account' using errcode = 'LOGIN';
  end if;

  -- Get the email to send account deletion token to
  select * into v_user_email
    from app_public.user_emails
    where user_id = app_public.current_user_id()
    order by is_primary desc, is_verified desc, id desc
    limit 1;

  -- Fetch or generate token
  update app_private.user_secrets
  set
    delete_account_token = (
      case
      when delete_account_token is null or delete_account_token_generated < NOW() - v_token_max_duration
      then encode(gen_random_bytes(7), 'hex')
      else delete_account_token
      end
    ),
    delete_account_token_generated = (
      case
      when delete_account_token is null or delete_account_token_generated < NOW() - v_token_max_duration
      then now()
      else delete_account_token_generated
      end
    )
  where user_id = app_public.current_user_id()
  returning delete_account_token into v_token;

  -- Trigger email send
  perform graphile_worker.add_job('user__send_delete_account_email', json_build_object('email', v_user_email.email::text, 'token', v_token));
  return true;
end;
$$;


--
-- Name: FUNCTION request_account_deletion(); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.request_account_deletion() IS 'Begin the account deletion flow by requesting the confirmation email';


--
-- Name: resend_email_verification_code(uuid); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.resend_email_verification_code(email_id uuid) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  if exists(
    select 1
    from app_public.user_emails
    where user_emails.id = email_id
    and user_id = app_public.current_user_id()
    and is_verified is false
  ) then
    perform graphile_worker.add_job('user_emails__send_verification', json_build_object('id', email_id));
    return true;
  end if;
  return false;
end;
$$;


--
-- Name: FUNCTION resend_email_verification_code(email_id uuid); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.resend_email_verification_code(email_id uuid) IS 'If you didn''t receive the verification code for this email, we can resend it. We silently cap the rate of resends on the backend, so calls to this function may not result in another email being sent if it has been called recently.';


--
-- Name: tg__friend_status(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.tg__friend_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if old.status = 'blocked' and
     new.status = 'accepted' then
    new.blocked_by = null;
  elseif old.status in ('accepted', 'blocked') and
         new.status = 'pending' then
    raise exception 'friend status cannot be changed back to pending';
  end if;
  return new;
end;
$$;


--
-- Name: tg__graphql_subscription(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.tg__graphql_subscription() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
  v_process_new bool = (TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
  v_process_old bool = (TG_OP = 'UPDATE' OR TG_OP = 'DELETE');
  v_event text = TG_ARGV[0];
  v_topic_template text = TG_ARGV[1];
  v_attribute text = TG_ARGV[2];
  v_record record;
  v_sub text;
  v_topic text;
  v_i int = 0;
  v_last_topic text;
begin
  for v_i in 0..1 loop
    if (v_i = 0) and v_process_new is true then
      v_record = new;
    elsif (v_i = 1) and v_process_old is true then
      v_record = old;
    else
      continue;
    end if;
     if v_attribute is not null then
      execute 'select $1.' || quote_ident(v_attribute)
        using v_record
        into v_sub;
    end if;
    if v_sub is not null then
      v_topic = replace(v_topic_template, '$1', v_sub);
    else
      v_topic = v_topic_template;
    end if;
    if v_topic is distinct from v_last_topic then
      -- This if statement prevents us from triggering the same notification twice
      v_last_topic = v_topic;
      perform pg_notify(v_topic, json_build_object(
        'event', v_event,
        'subject', v_sub,
        'id', v_record.id
      )::text);
    end if;
  end loop;
  return v_record;
end;
$_$;


--
-- Name: FUNCTION tg__graphql_subscription(); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.tg__graphql_subscription() IS 'This function enables the creation of simple focussed GraphQL subscriptions using database triggers. Read more here: https://www.graphile.org/postgraphile/subscriptions/#custom-subscriptions';


--
-- Name: tg_user_emails__forbid_if_verified(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.tg_user_emails__forbid_if_verified() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  if exists(select 1 from app_public.user_emails where email = NEW.email and is_verified is true) then
    raise exception 'An account using that email address has already been created.' using errcode='EMTKN';
  end if;
  return NEW;
end;
$$;


--
-- Name: tg_user_emails__prevent_delete_last_email(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.tg_user_emails__prevent_delete_last_email() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  if exists (
    with remaining as (
      select user_emails.user_id
      from app_public.user_emails
      inner join deleted
      on user_emails.user_id = deleted.user_id
      -- Don't delete last verified email
      where (user_emails.is_verified is true or not exists (
        select 1
        from deleted d2
        where d2.user_id = user_emails.user_id
        and d2.is_verified is true
      ))
      order by user_emails.id asc

      /*
       * Lock this table to prevent race conditions; see:
       * https://www.cybertec-postgresql.com/en/triggers-to-enforce-constraints/
       */
      for update of user_emails
    )
    select 1
    from app_public.users
    where id in (
      select user_id from deleted
      except
      select user_id from remaining
    )
  )
  then
    raise exception 'You must have at least one (verified) email address' using errcode = 'CDLEA';
  end if;

  return null;
end;
$$;


--
-- Name: tg_user_emails__verify_account_on_verified(); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.tg_user_emails__verify_account_on_verified() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  update app_public.users set is_verified = true where id = new.user_id and is_verified is false;
  return new;
end;
$$;


--
-- Name: users_check_in_statistics(app_public.users); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.users_check_in_statistics(u app_public.users) RETURNS TABLE(total_check_ins integer, unique_check_ins integer)
    LANGUAGE sql STABLE
    AS $$
  SELECT
    count(*) AS total_check_ins,
    count(DISTINCT item_id) AS unique_check_ins
  FROM
    app_public.check_ins
  WHERE
    author_id = u.id;

$$;


--
-- Name: users_has_password(app_public.users); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.users_has_password(u app_public.users) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
  select (password_hash is not null) from app_private.user_secrets where user_secrets.user_id = u.id and u.id = app_public.current_user_id();
$$;


--
-- Name: verify_email(uuid, text); Type: FUNCTION; Schema: app_public; Owner: -
--

CREATE FUNCTION app_public.verify_email(user_email_id uuid, token text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  update app_public.user_emails
  set
    is_verified = true,
    is_primary = is_primary or not exists(
      select 1 from app_public.user_emails other_email where other_email.user_id = user_emails.user_id and other_email.is_primary is true
    )
  where id = user_email_id
  and exists(
    select 1 from app_private.user_email_secrets where user_email_secrets.user_email_id = user_emails.id and verification_token = token
  );
  return found;
end;
$$;


--
-- Name: FUNCTION verify_email(user_email_id uuid, token text); Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON FUNCTION app_public.verify_email(user_email_id uuid, token text) IS 'Once you have received a verification token for your email, you may call this mutation with that token to make your email verified.';


--
-- Name: connect_pg_simple_sessions; Type: TABLE; Schema: app_private; Owner: -
--

CREATE TABLE app_private.connect_pg_simple_sessions (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp without time zone NOT NULL
);


--
-- Name: transferable_check_ins; Type: TABLE; Schema: app_private; Owner: -
--

CREATE TABLE app_private.transferable_check_ins (
    company text,
    brand text,
    flavor text,
    category text,
    style text,
    rating text
);


--
-- Name: unregistered_email_password_resets; Type: TABLE; Schema: app_private; Owner: -
--

CREATE TABLE app_private.unregistered_email_password_resets (
    email public.citext NOT NULL,
    attempts integer DEFAULT 1 NOT NULL,
    latest_attempt timestamp with time zone NOT NULL
);


--
-- Name: TABLE unregistered_email_password_resets; Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON TABLE app_private.unregistered_email_password_resets IS 'If someone tries to recover the password for an email that is not registered in our system, this table enables us to rate-limit outgoing emails to avoid spamming.';


--
-- Name: COLUMN unregistered_email_password_resets.attempts; Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON COLUMN app_private.unregistered_email_password_resets.attempts IS 'We store the number of attempts to help us detect accounts being attacked.';


--
-- Name: COLUMN unregistered_email_password_resets.latest_attempt; Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON COLUMN app_private.unregistered_email_password_resets.latest_attempt IS 'We store the time the last password reset was sent to this email to prevent the email getting flooded.';


--
-- Name: user_authentication_secrets; Type: TABLE; Schema: app_private; Owner: -
--

CREATE TABLE app_private.user_authentication_secrets (
    user_authentication_id uuid NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- Name: user_email_secrets; Type: TABLE; Schema: app_private; Owner: -
--

CREATE TABLE app_private.user_email_secrets (
    user_email_id uuid NOT NULL,
    verification_token text,
    verification_email_sent_at timestamp with time zone,
    password_reset_email_sent_at timestamp with time zone
);


--
-- Name: TABLE user_email_secrets; Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON TABLE app_private.user_email_secrets IS 'The contents of this table should never be visible to the user. Contains data mostly related to email verification and avoiding spamming users.';


--
-- Name: COLUMN user_email_secrets.password_reset_email_sent_at; Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON COLUMN app_private.user_email_secrets.password_reset_email_sent_at IS 'We store the time the last password reset was sent to this email to prevent the email getting flooded.';


--
-- Name: user_secrets; Type: TABLE; Schema: app_private; Owner: -
--

CREATE TABLE app_private.user_secrets (
    user_id uuid NOT NULL,
    password_hash text,
    last_login_at timestamp with time zone DEFAULT now() NOT NULL,
    failed_password_attempts integer DEFAULT 0 NOT NULL,
    first_failed_password_attempt timestamp with time zone,
    reset_password_token text,
    reset_password_token_generated timestamp with time zone,
    failed_reset_password_attempts integer DEFAULT 0 NOT NULL,
    first_failed_reset_password_attempt timestamp with time zone,
    delete_account_token text,
    delete_account_token_generated timestamp with time zone,
    role app_private.role DEFAULT 'user'::app_private.role
);


--
-- Name: TABLE user_secrets; Type: COMMENT; Schema: app_private; Owner: -
--

COMMENT ON TABLE app_private.user_secrets IS 'The contents of this table should never be visible to the user. Contains data mostly related to authentication.';


--
-- Name: friends; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.friends (
    user_id_1 uuid NOT NULL,
    user_id_2 uuid NOT NULL,
    status app_public.friend_status DEFAULT 'pending'::app_public.friend_status NOT NULL,
    sent date DEFAULT now() NOT NULL,
    accepted date,
    blocked_by uuid,
    CONSTRAINT friends_check CHECK ((user_id_1 <> user_id_2))
);


--
-- Name: activity_feed; Type: VIEW; Schema: app_public; Owner: -
--

CREATE VIEW app_public.activity_feed AS
 SELECT check_ins.id,
    check_ins.rating,
    check_ins.review,
    check_ins.item_id,
    check_ins.author_id,
    check_ins.check_in_date,
    check_ins.location,
    check_ins.is_public,
    check_ins.created_at,
    check_ins.likes
   FROM (app_public.check_ins
     LEFT JOIN app_public.friends f ON (((check_ins.author_id = f.user_id_2) OR (check_ins.author_id = f.user_id_1))))
  WHERE (f.status = 'accepted'::app_public.friend_status)
  ORDER BY check_ins.created_at;


--
-- Name: VIEW activity_feed; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON VIEW app_public.activity_feed IS '@foreignKey (item_id) references app_public.items(id)
@foreignKey (author_id) references app_public.users(id)';


--
-- Name: brands_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.brands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brands_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.brands_id_seq OWNED BY app_public.brands.id;


--
-- Name: categories; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.categories (
    name character varying(40) NOT NULL
);


--
-- Name: TABLE categories; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.categories IS 'Main categories for items';


--
-- Name: check_in_comments_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.check_in_comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_in_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.check_in_comments_id_seq OWNED BY app_public.check_in_comments.id;


--
-- Name: check_in_friends; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.check_in_friends (
    check_in_id integer,
    friend_id uuid
);


--
-- Name: check_in_likes; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.check_in_likes (
    id integer NOT NULL,
    liked_by uuid
);


--
-- Name: check_in_likes_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.check_in_likes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_in_likes_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.check_in_likes_id_seq OWNED BY app_public.check_in_likes.id;


--
-- Name: check_in_tags; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.check_in_tags (
    check_in_id integer NOT NULL,
    tag_id integer NOT NULL
);


--
-- Name: check_ins_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.check_ins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: check_ins_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.check_ins_id_seq OWNED BY app_public.check_ins.id;


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.companies_id_seq OWNED BY app_public.companies.id;


--
-- Name: item_edit_suggestions; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.item_edit_suggestions (
    id integer NOT NULL,
    description app_public.long_text,
    flavor app_public.short_text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id integer NOT NULL,
    manufacturer_id integer,
    brand_id integer NOT NULL,
    author_id uuid NOT NULL,
    accepted timestamp with time zone,
    type_id integer NOT NULL
);


--
-- Name: item_edit_suggestions_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.item_edit_suggestions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_edit_suggestions_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.item_edit_suggestions_id_seq OWNED BY app_public.item_edit_suggestions.id;


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.items_id_seq OWNED BY app_public.items.id;


--
-- Name: public_check_ins; Type: VIEW; Schema: app_public; Owner: -
--

CREATE VIEW app_public.public_check_ins AS
 SELECT check_ins.id,
    check_ins.rating,
    check_ins.review,
    check_ins.item_id,
    check_ins.author_id,
    check_ins.check_in_date,
    check_ins.location,
    check_ins.is_public,
    check_ins.created_at
   FROM app_public.check_ins
  WHERE (check_ins.is_public IS TRUE);


--
-- Name: user_settings; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.user_settings (
    id uuid NOT NULL,
    is_public_check_ins boolean DEFAULT true,
    is_public boolean DEFAULT true
);


--
-- Name: public_users; Type: VIEW; Schema: app_public; Owner: -
--

CREATE VIEW app_public.public_users AS
 WITH public_users AS (
         SELECT u.id,
            u.username,
            u.avatar_url,
            u.is_admin,
            u.is_verified,
            u.created_at,
            u.updated_at,
            u.first_name,
            u.last_name,
            u.location,
            u.country
           FROM (app_public.users u
             LEFT JOIN app_public.user_settings s ON ((u.id = s.id)))
          WHERE (s.is_public = true)
        )
 SELECT p.id,
    p.username,
    p.avatar_url,
    p.is_admin,
    p.is_verified,
    p.created_at,
    p.updated_at,
    p.first_name,
    p.last_name,
    p.location,
    p.country,
    f.status
   FROM (public_users p
     LEFT JOIN app_public.friends f ON ((((f.user_id_1 = app_public.current_user_id()) AND (p.id = f.user_id_2)) OR ((f.user_id_1 = p.id) AND (f.user_id_1 = app_public.current_user_id())))))
  WHERE (p.id <> app_public.current_user_id());


--
-- Name: tags; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.tags (
    id integer NOT NULL,
    name text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    CONSTRAINT tag_name_check CHECK (((length(name) >= 2) AND (length(name) <= 10)))
);


--
-- Name: TABLE tags; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.tags IS 'Tag for an item or check-in';


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.tags_id_seq OWNED BY app_public.tags.id;


--
-- Name: types; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.types (
    id integer NOT NULL,
    name text NOT NULL,
    category text NOT NULL
);


--
-- Name: TABLE types; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.types IS 'Type item that is part of a category';


--
-- Name: types_id_seq; Type: SEQUENCE; Schema: app_public; Owner: -
--

CREATE SEQUENCE app_public.types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: types_id_seq; Type: SEQUENCE OWNED BY; Schema: app_public; Owner: -
--

ALTER SEQUENCE app_public.types_id_seq OWNED BY app_public.types.id;


--
-- Name: user_authentications; Type: TABLE; Schema: app_public; Owner: -
--

CREATE TABLE app_public.user_authentications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    service text NOT NULL,
    identifier text NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE user_authentications; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON TABLE app_public.user_authentications IS 'Contains information about the login providers this user has used, so that they may disconnect them should they wish.';


--
-- Name: COLUMN user_authentications.service; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.user_authentications.service IS 'The login service used, e.g. `twitter` or `github`.';


--
-- Name: COLUMN user_authentications.identifier; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.user_authentications.identifier IS 'A unique identifier for the user within the login service.';


--
-- Name: COLUMN user_authentications.details; Type: COMMENT; Schema: app_public; Owner: -
--

COMMENT ON COLUMN app_public.user_authentications.details IS 'Additional profile details extracted from this login method';


--
-- Name: brands id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.brands ALTER COLUMN id SET DEFAULT nextval('app_public.brands_id_seq'::regclass);


--
-- Name: check_in_comments id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_comments ALTER COLUMN id SET DEFAULT nextval('app_public.check_in_comments_id_seq'::regclass);


--
-- Name: check_in_likes id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_likes ALTER COLUMN id SET DEFAULT nextval('app_public.check_in_likes_id_seq'::regclass);


--
-- Name: check_ins id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_ins ALTER COLUMN id SET DEFAULT nextval('app_public.check_ins_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.companies ALTER COLUMN id SET DEFAULT nextval('app_public.companies_id_seq'::regclass);


--
-- Name: item_edit_suggestions id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.item_edit_suggestions ALTER COLUMN id SET DEFAULT nextval('app_public.item_edit_suggestions_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items ALTER COLUMN id SET DEFAULT nextval('app_public.items_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.tags ALTER COLUMN id SET DEFAULT nextval('app_public.tags_id_seq'::regclass);


--
-- Name: types id; Type: DEFAULT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.types ALTER COLUMN id SET DEFAULT nextval('app_public.types_id_seq'::regclass);


--
-- Name: connect_pg_simple_sessions session_pkey; Type: CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.connect_pg_simple_sessions
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (uuid);


--
-- Name: unregistered_email_password_resets unregistered_email_pkey; Type: CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.unregistered_email_password_resets
    ADD CONSTRAINT unregistered_email_pkey PRIMARY KEY (email);


--
-- Name: user_authentication_secrets user_authentication_secrets_pkey; Type: CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.user_authentication_secrets
    ADD CONSTRAINT user_authentication_secrets_pkey PRIMARY KEY (user_authentication_id);


--
-- Name: user_email_secrets user_email_secrets_pkey; Type: CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.user_email_secrets
    ADD CONSTRAINT user_email_secrets_pkey PRIMARY KEY (user_email_id);


--
-- Name: user_secrets user_secrets_pkey; Type: CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.user_secrets
    ADD CONSTRAINT user_secrets_pkey PRIMARY KEY (user_id);


--
-- Name: brands brands_company_id_name_key; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.brands
    ADD CONSTRAINT brands_company_id_name_key UNIQUE (company_id, name);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (name);


--
-- Name: check_in_comments check_in_comments_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_comments
    ADD CONSTRAINT check_in_comments_pkey PRIMARY KEY (id);


--
-- Name: check_in_likes check_in_likes_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_likes
    ADD CONSTRAINT check_in_likes_pkey PRIMARY KEY (id);


--
-- Name: check_in_tags check_in_tags_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_tags
    ADD CONSTRAINT check_in_tags_pkey PRIMARY KEY (check_in_id, tag_id);


--
-- Name: check_ins check_ins_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_ins
    ADD CONSTRAINT check_ins_pkey PRIMARY KEY (id);


--
-- Name: companies companies_name_key; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.companies
    ADD CONSTRAINT companies_name_key UNIQUE (name);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: friends friends_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.friends
    ADD CONSTRAINT friends_pkey PRIMARY KEY (user_id_1, user_id_2);


--
-- Name: item_edit_suggestions item_edit_suggestions_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.item_edit_suggestions
    ADD CONSTRAINT item_edit_suggestions_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: items itens_brand_id_flavor_key; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items
    ADD CONSTRAINT itens_brand_id_flavor_key UNIQUE (brand_id, flavor);


--
-- Name: tags tags_name_key; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.tags
    ADD CONSTRAINT tags_name_key UNIQUE (name);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: types types_name_category_key; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.types
    ADD CONSTRAINT types_name_category_key UNIQUE (name, category);


--
-- Name: types types_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.types
    ADD CONSTRAINT types_pkey PRIMARY KEY (id);


--
-- Name: user_authentications uniq_user_authentications; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_authentications
    ADD CONSTRAINT uniq_user_authentications UNIQUE (service, identifier);


--
-- Name: user_authentications user_authentications_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_authentications
    ADD CONSTRAINT user_authentications_pkey PRIMARY KEY (id);


--
-- Name: user_emails user_emails_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_emails
    ADD CONSTRAINT user_emails_pkey PRIMARY KEY (id);


--
-- Name: user_emails user_emails_user_id_email_key; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_emails
    ADD CONSTRAINT user_emails_user_id_email_key UNIQUE (user_id, email);


--
-- Name: user_settings user_settings_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_settings
    ADD CONSTRAINT user_settings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: app_private; Owner: -
--

CREATE INDEX sessions_user_id_idx ON app_private.sessions USING btree (user_id);


--
-- Name: brands_created_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX brands_created_by_idx ON app_public.brands USING btree (created_by);


--
-- Name: check_in_comments_check_in_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_in_comments_check_in_id_idx ON app_public.check_in_comments USING btree (check_in_id);


--
-- Name: check_in_comments_created_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_in_comments_created_by_idx ON app_public.check_in_comments USING btree (created_by);


--
-- Name: check_in_friends_check_in_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_in_friends_check_in_id_idx ON app_public.check_in_friends USING btree (check_in_id);


--
-- Name: check_in_friends_friend_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_in_friends_friend_id_idx ON app_public.check_in_friends USING btree (friend_id);


--
-- Name: check_in_likes_liked_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_in_likes_liked_by_idx ON app_public.check_in_likes USING btree (liked_by);


--
-- Name: check_in_tags_tag_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_in_tags_tag_id_idx ON app_public.check_in_tags USING btree (tag_id);


--
-- Name: check_ins_author_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_ins_author_idx ON app_public.check_ins USING btree (author_id);


--
-- Name: check_ins_created_at_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_ins_created_at_idx ON app_public.check_ins USING btree (created_at);


--
-- Name: check_ins_item_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_ins_item_id_idx ON app_public.check_ins USING btree (item_id);


--
-- Name: check_ins_item_id_idx1; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_ins_item_id_idx1 ON app_public.check_ins USING btree (item_id);


--
-- Name: check_ins_location_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX check_ins_location_idx ON app_public.check_ins USING btree (location);


--
-- Name: companies_created_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX companies_created_by_idx ON app_public.companies USING btree (created_by);


--
-- Name: companies_name_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX companies_name_idx ON app_public.companies USING btree (name);


--
-- Name: friends_blocked_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX friends_blocked_by_idx ON app_public.friends USING btree (blocked_by);


--
-- Name: friends_user_id_1_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX friends_user_id_1_idx ON app_public.friends USING btree (user_id_1);


--
-- Name: friends_user_id_2_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX friends_user_id_2_idx ON app_public.friends USING btree (user_id_2);


--
-- Name: idx_user_emails_primary; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX idx_user_emails_primary ON app_public.user_emails USING btree (is_primary, user_id);


--
-- Name: idx_user_emails_user; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX idx_user_emails_user ON app_public.user_emails USING btree (user_id);


--
-- Name: item_edit_suggestions_author_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX item_edit_suggestions_author_id_idx ON app_public.item_edit_suggestions USING btree (author_id);


--
-- Name: item_edit_suggestions_brand_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX item_edit_suggestions_brand_id_idx ON app_public.item_edit_suggestions USING btree (brand_id);


--
-- Name: item_edit_suggestions_item_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX item_edit_suggestions_item_id_idx ON app_public.item_edit_suggestions USING btree (item_id);


--
-- Name: item_edit_suggestions_manufacturer_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX item_edit_suggestions_manufacturer_id_idx ON app_public.item_edit_suggestions USING btree (manufacturer_id);


--
-- Name: item_edit_suggestions_type_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX item_edit_suggestions_type_id_idx ON app_public.item_edit_suggestions USING btree (type_id);


--
-- Name: item_edit_suggestions_type_id_idx1; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX item_edit_suggestions_type_id_idx1 ON app_public.item_edit_suggestions USING btree (type_id);


--
-- Name: items_brand_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_brand_id_idx ON app_public.items USING btree (brand_id);


--
-- Name: items_brand_id_idx1; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_brand_id_idx1 ON app_public.items USING btree (brand_id);


--
-- Name: items_created_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_created_by_idx ON app_public.items USING btree (created_by);


--
-- Name: items_flavor_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_flavor_idx ON app_public.items USING btree (flavor);


--
-- Name: items_manufacturer_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_manufacturer_idx ON app_public.items USING btree (manufacturer_id);


--
-- Name: items_type_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_type_id_idx ON app_public.items USING btree (type_id);


--
-- Name: items_type_id_idx1; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_type_id_idx1 ON app_public.items USING btree (type_id);


--
-- Name: items_updated_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX items_updated_by_idx ON app_public.items USING btree (updated_by);


--
-- Name: tags_created_by_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX tags_created_by_idx ON app_public.tags USING btree (created_by);


--
-- Name: types_category_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX types_category_idx ON app_public.types USING btree (category);


--
-- Name: uniq_user_emails_primary_email; Type: INDEX; Schema: app_public; Owner: -
--

CREATE UNIQUE INDEX uniq_user_emails_primary_email ON app_public.user_emails USING btree (user_id) WHERE (is_primary IS TRUE);


--
-- Name: uniq_user_emails_verified_email; Type: INDEX; Schema: app_public; Owner: -
--

CREATE UNIQUE INDEX uniq_user_emails_verified_email ON app_public.user_emails USING btree (email) WHERE (is_verified IS TRUE);


--
-- Name: unique_friend_relation_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE UNIQUE INDEX unique_friend_relation_idx ON app_public.friends USING btree (LEAST(user_id_1, user_id_2), GREATEST(user_id_1, user_id_2));


--
-- Name: user_authentications_user_id_idx; Type: INDEX; Schema: app_public; Owner: -
--

CREATE INDEX user_authentications_user_id_idx ON app_public.user_authentications USING btree (user_id);


--
-- Name: tags _100_timestamps; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _100_timestamps BEFORE INSERT ON app_public.tags FOR EACH ROW EXECUTE FUNCTION app_private.tg__created();


--
-- Name: user_authentications _100_timestamps; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _100_timestamps BEFORE INSERT OR UPDATE ON app_public.user_authentications FOR EACH ROW EXECUTE FUNCTION app_private.tg__timestamps();


--
-- Name: user_emails _100_timestamps; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _100_timestamps BEFORE INSERT OR UPDATE ON app_public.user_emails FOR EACH ROW EXECUTE FUNCTION app_private.tg__timestamps();


--
-- Name: users _100_timestamps; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _100_timestamps BEFORE INSERT OR UPDATE ON app_public.users FOR EACH ROW EXECUTE FUNCTION app_private.tg__timestamps();


--
-- Name: user_emails _200_forbid_existing_email; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _200_forbid_existing_email BEFORE INSERT ON app_public.user_emails FOR EACH ROW EXECUTE FUNCTION app_public.tg_user_emails__forbid_if_verified();


--
-- Name: user_emails _500_audit_added; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_audit_added AFTER INSERT ON app_public.user_emails FOR EACH ROW EXECUTE FUNCTION app_private.tg__add_audit_job('added_email', 'user_id', 'id', 'email');


--
-- Name: user_authentications _500_audit_removed; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_audit_removed AFTER DELETE ON app_public.user_authentications FOR EACH ROW EXECUTE FUNCTION app_private.tg__add_audit_job('unlinked_account', 'user_id', 'service', 'identifier');


--
-- Name: user_emails _500_audit_removed; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_audit_removed AFTER DELETE ON app_public.user_emails FOR EACH ROW EXECUTE FUNCTION app_private.tg__add_audit_job('removed_email', 'user_id', 'id', 'email');


--
-- Name: users _500_gql_update; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_gql_update AFTER UPDATE ON app_public.users FOR EACH ROW EXECUTE FUNCTION app_public.tg__graphql_subscription('userChanged', 'graphql:user:$1', 'id');


--
-- Name: user_emails _500_insert_secrets; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_insert_secrets AFTER INSERT ON app_public.user_emails FOR EACH ROW EXECUTE FUNCTION app_private.tg_user_email_secrets__insert_with_user_email();


--
-- Name: users _500_insert_secrets; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_insert_secrets AFTER INSERT ON app_public.users FOR EACH ROW EXECUTE FUNCTION app_private.tg_user_secrets__insert_with_user();


--
-- Name: user_emails _500_prevent_delete_last; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_prevent_delete_last AFTER DELETE ON app_public.user_emails REFERENCING OLD TABLE AS deleted FOR EACH STATEMENT EXECUTE FUNCTION app_public.tg_user_emails__prevent_delete_last_email();


--
-- Name: user_emails _500_verify_account_on_verified; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _500_verify_account_on_verified AFTER INSERT OR UPDATE OF is_verified ON app_public.user_emails FOR EACH ROW WHEN ((new.is_verified IS TRUE)) EXECUTE FUNCTION app_public.tg_user_emails__verify_account_on_verified();


--
-- Name: user_emails _900_send_verification_email; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER _900_send_verification_email AFTER INSERT ON app_public.user_emails FOR EACH ROW WHEN ((new.is_verified IS FALSE)) EXECUTE FUNCTION app_private.tg__add_job('user_emails__send_verification');


--
-- Name: friends check_friendship_status; Type: TRIGGER; Schema: app_public; Owner: -
--

CREATE TRIGGER check_friendship_status BEFORE UPDATE ON app_public.friends FOR EACH ROW EXECUTE FUNCTION app_public.tg__friend_status();


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: user_authentication_secrets user_authentication_secrets_user_authentication_id_fkey; Type: FK CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.user_authentication_secrets
    ADD CONSTRAINT user_authentication_secrets_user_authentication_id_fkey FOREIGN KEY (user_authentication_id) REFERENCES app_public.user_authentications(id) ON DELETE CASCADE;


--
-- Name: user_email_secrets user_email_secrets_user_email_id_fkey; Type: FK CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.user_email_secrets
    ADD CONSTRAINT user_email_secrets_user_email_id_fkey FOREIGN KEY (user_email_id) REFERENCES app_public.user_emails(id) ON DELETE CASCADE;


--
-- Name: user_secrets user_secrets_user_id_fkey; Type: FK CONSTRAINT; Schema: app_private; Owner: -
--

ALTER TABLE ONLY app_private.user_secrets
    ADD CONSTRAINT user_secrets_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: brands brands_company_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.brands
    ADD CONSTRAINT brands_company_id_fkey FOREIGN KEY (company_id) REFERENCES app_public.companies(id) ON DELETE CASCADE;


--
-- Name: brands brands_created_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.brands
    ADD CONSTRAINT brands_created_by_fkey FOREIGN KEY (created_by) REFERENCES app_public.users(id) ON DELETE SET NULL;


--
-- Name: check_in_comments check_in_comments_check_in_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_comments
    ADD CONSTRAINT check_in_comments_check_in_id_fkey FOREIGN KEY (check_in_id) REFERENCES app_public.check_ins(id) ON DELETE CASCADE;


--
-- Name: check_in_comments check_in_comments_created_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_comments
    ADD CONSTRAINT check_in_comments_created_by_fkey FOREIGN KEY (created_by) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: check_in_friends check_in_friends_check_in_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_friends
    ADD CONSTRAINT check_in_friends_check_in_id_fkey FOREIGN KEY (check_in_id) REFERENCES app_public.check_ins(id) ON DELETE CASCADE;


--
-- Name: check_in_friends check_in_friends_friend_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_friends
    ADD CONSTRAINT check_in_friends_friend_id_fkey FOREIGN KEY (friend_id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: check_in_likes check_in_likes_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_likes
    ADD CONSTRAINT check_in_likes_id_fkey FOREIGN KEY (id) REFERENCES app_public.check_ins(id) ON DELETE CASCADE;


--
-- Name: check_in_likes check_in_likes_liked_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_likes
    ADD CONSTRAINT check_in_likes_liked_by_fkey FOREIGN KEY (liked_by) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: check_in_tags check_in_tags_check_in_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_tags
    ADD CONSTRAINT check_in_tags_check_in_id_fkey FOREIGN KEY (check_in_id) REFERENCES app_public.check_ins(id) ON DELETE CASCADE;


--
-- Name: check_in_tags check_in_tags_tag_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_in_tags
    ADD CONSTRAINT check_in_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES app_public.tags(id) ON DELETE CASCADE;


--
-- Name: check_ins check_ins_author_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_ins
    ADD CONSTRAINT check_ins_author_fkey FOREIGN KEY (author_id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: check_ins check_ins_item_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.check_ins
    ADD CONSTRAINT check_ins_item_id_fkey FOREIGN KEY (item_id) REFERENCES app_public.items(id) ON DELETE CASCADE;


--
-- Name: companies companies_created_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.companies
    ADD CONSTRAINT companies_created_by_fkey FOREIGN KEY (created_by) REFERENCES app_public.users(id) ON DELETE SET NULL;


--
-- Name: friends friends_blocked_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.friends
    ADD CONSTRAINT friends_blocked_by_fkey FOREIGN KEY (blocked_by) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: friends friends_user_id_1_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.friends
    ADD CONSTRAINT friends_user_id_1_fkey FOREIGN KEY (user_id_1) REFERENCES app_public.users(id);


--
-- Name: friends friends_user_id_2_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.friends
    ADD CONSTRAINT friends_user_id_2_fkey FOREIGN KEY (user_id_2) REFERENCES app_public.users(id);


--
-- Name: item_edit_suggestions item_edit_suggestions_author_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.item_edit_suggestions
    ADD CONSTRAINT item_edit_suggestions_author_id_fkey FOREIGN KEY (author_id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: item_edit_suggestions item_edit_suggestions_brand_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.item_edit_suggestions
    ADD CONSTRAINT item_edit_suggestions_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES app_public.brands(id) ON DELETE CASCADE;


--
-- Name: item_edit_suggestions item_edit_suggestions_item_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.item_edit_suggestions
    ADD CONSTRAINT item_edit_suggestions_item_id_fkey FOREIGN KEY (item_id) REFERENCES app_public.items(id) ON DELETE CASCADE;


--
-- Name: item_edit_suggestions item_edit_suggestions_manufacturer_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.item_edit_suggestions
    ADD CONSTRAINT item_edit_suggestions_manufacturer_id_fkey FOREIGN KEY (manufacturer_id) REFERENCES app_public.companies(id) ON DELETE CASCADE;


--
-- Name: item_edit_suggestions item_edit_suggestions_type_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.item_edit_suggestions
    ADD CONSTRAINT item_edit_suggestions_type_id_fkey FOREIGN KEY (type_id) REFERENCES app_public.types(id);


--
-- Name: items items_brand_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items
    ADD CONSTRAINT items_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES app_public.brands(id) ON DELETE CASCADE;


--
-- Name: items items_created_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items
    ADD CONSTRAINT items_created_by_fkey FOREIGN KEY (created_by) REFERENCES app_public.users(id) ON DELETE SET NULL;


--
-- Name: items items_manufacturer_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items
    ADD CONSTRAINT items_manufacturer_fkey FOREIGN KEY (manufacturer_id) REFERENCES app_public.companies(id) ON DELETE CASCADE;


--
-- Name: items items_type_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items
    ADD CONSTRAINT items_type_id_fkey FOREIGN KEY (type_id) REFERENCES app_public.types(id) ON DELETE CASCADE;


--
-- Name: items items_updated_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.items
    ADD CONSTRAINT items_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES app_public.users(id) ON DELETE SET NULL;


--
-- Name: tags tags_created_by_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.tags
    ADD CONSTRAINT tags_created_by_fkey FOREIGN KEY (created_by) REFERENCES app_public.users(id) ON DELETE SET NULL;


--
-- Name: types types_category_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.types
    ADD CONSTRAINT types_category_fkey FOREIGN KEY (category) REFERENCES app_public.categories(name) ON DELETE CASCADE;


--
-- Name: user_authentications user_authentications_user_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_authentications
    ADD CONSTRAINT user_authentications_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: user_emails user_emails_user_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_emails
    ADD CONSTRAINT user_emails_user_id_fkey FOREIGN KEY (user_id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: user_settings user_settings_id_fkey; Type: FK CONSTRAINT; Schema: app_public; Owner: -
--

ALTER TABLE ONLY app_public.user_settings
    ADD CONSTRAINT user_settings_id_fkey FOREIGN KEY (id) REFERENCES app_public.users(id) ON DELETE CASCADE;


--
-- Name: connect_pg_simple_sessions; Type: ROW SECURITY; Schema: app_private; Owner: -
--

ALTER TABLE app_private.connect_pg_simple_sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: app_private; Owner: -
--

ALTER TABLE app_private.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: user_authentication_secrets; Type: ROW SECURITY; Schema: app_private; Owner: -
--

ALTER TABLE app_private.user_authentication_secrets ENABLE ROW LEVEL SECURITY;

--
-- Name: user_email_secrets; Type: ROW SECURITY; Schema: app_private; Owner: -
--

ALTER TABLE app_private.user_email_secrets ENABLE ROW LEVEL SECURITY;

--
-- Name: user_secrets; Type: ROW SECURITY; Schema: app_private; Owner: -
--

ALTER TABLE app_private.user_secrets ENABLE ROW LEVEL SECURITY;

--
-- Name: brands; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.brands ENABLE ROW LEVEL SECURITY;

--
-- Name: categories; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.categories ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_comments; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.check_in_comments ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_friends; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.check_in_friends ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_likes; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.check_in_likes ENABLE ROW LEVEL SECURITY;

--
-- Name: check_in_tags; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.check_in_tags ENABLE ROW LEVEL SECURITY;

--
-- Name: check_ins; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.check_ins ENABLE ROW LEVEL SECURITY;

--
-- Name: companies; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.companies ENABLE ROW LEVEL SECURITY;

--
-- Name: check_ins create_check_in; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY create_check_in ON app_public.check_ins FOR INSERT WITH CHECK ((app_public.current_user_id() IS NOT NULL));


--
-- Name: companies create_companies; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY create_companies ON app_public.companies FOR INSERT WITH CHECK (((created_by = app_public.current_user_id()) AND (created_by IS NOT NULL)));


--
-- Name: check_ins delete_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY delete_own ON app_public.check_ins FOR DELETE USING ((author_id = app_public.current_user_id()));


--
-- Name: friends delete_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY delete_own ON app_public.friends FOR DELETE USING ((EXISTS ( SELECT 1
   FROM app_public.friends friends_1
  WHERE ((friends_1.user_id_1 = app_public.current_user_id()) OR (friends_1.user_id_2 = app_public.current_user_id())))));


--
-- Name: user_authentications delete_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY delete_own ON app_public.user_authentications FOR DELETE USING ((user_id = app_public.current_user_id()));


--
-- Name: user_emails delete_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY delete_own ON app_public.user_emails FOR DELETE USING ((user_id = app_public.current_user_id()));


--
-- Name: friends; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.friends ENABLE ROW LEVEL SECURITY;

--
-- Name: user_emails insert_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY insert_own ON app_public.user_emails FOR INSERT WITH CHECK ((user_id = app_public.current_user_id()));


--
-- Name: item_edit_suggestions; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.item_edit_suggestions ENABLE ROW LEVEL SECURITY;

--
-- Name: items; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.items ENABLE ROW LEVEL SECURITY;

--
-- Name: tags logged_in_insert; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY logged_in_insert ON app_public.tags FOR INSERT WITH CHECK ((app_public.current_user_id() IS NOT NULL));


--
-- Name: brands moderator_delete; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_delete ON app_public.brands FOR DELETE USING (app_public.current_user_is_privileged());


--
-- Name: check_ins moderator_delete; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_delete ON app_public.check_ins FOR DELETE USING (app_public.current_user_is_privileged());


--
-- Name: companies moderator_delete; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_delete ON app_public.companies FOR DELETE USING (app_public.current_user_is_privileged());


--
-- Name: items moderator_delete; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_delete ON app_public.items FOR DELETE USING (app_public.current_user_is_privileged());


--
-- Name: tags moderator_delete; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_delete ON app_public.tags FOR DELETE USING (app_public.current_user_is_privileged());


--
-- Name: brands moderator_update; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_update ON app_public.brands FOR UPDATE USING (app_public.current_user_is_privileged());


--
-- Name: companies moderator_update; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_update ON app_public.companies FOR UPDATE USING (app_public.current_user_is_privileged());


--
-- Name: items moderator_update; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_update ON app_public.items FOR UPDATE USING (app_public.current_user_is_privileged());


--
-- Name: tags moderator_update; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_update ON app_public.tags FOR UPDATE USING (app_public.current_user_is_privileged());


--
-- Name: types moderator_update; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY moderator_update ON app_public.types FOR INSERT WITH CHECK (app_public.current_user_is_privileged());


--
-- Name: brands select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.brands FOR SELECT USING (true);


--
-- Name: categories select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.categories FOR SELECT USING (true);


--
-- Name: companies select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.companies FOR SELECT USING (true);


--
-- Name: item_edit_suggestions select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.item_edit_suggestions FOR SELECT USING (app_public.current_user_is_privileged());


--
-- Name: items select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.items FOR SELECT USING (true);


--
-- Name: tags select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.tags FOR SELECT USING (true);


--
-- Name: types select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.types FOR SELECT USING (true);


--
-- Name: users select_all; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_all ON app_public.users FOR SELECT USING (true);


--
-- Name: check_ins select_friends; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_friends ON app_public.check_ins FOR SELECT USING ((author_id IN ( SELECT app_public.current_user_friends() AS current_user_friends)));


--
-- Name: user_authentications select_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_own ON app_public.user_authentications FOR SELECT USING ((user_id = app_public.current_user_id()));


--
-- Name: user_emails select_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_own ON app_public.user_emails FOR SELECT USING ((user_id = app_public.current_user_id()));


--
-- Name: check_ins select_public; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY select_public ON app_public.check_ins FOR SELECT USING ((is_public = true));


--
-- Name: tags; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.tags ENABLE ROW LEVEL SECURITY;

--
-- Name: types; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.types ENABLE ROW LEVEL SECURITY;

--
-- Name: check_ins update_own; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY update_own ON app_public.check_ins FOR UPDATE USING ((author_id = app_public.current_user_id()));


--
-- Name: users update_self; Type: POLICY; Schema: app_public; Owner: -
--

CREATE POLICY update_self ON app_public.users FOR UPDATE USING ((id = app_public.current_user_id()));


--
-- Name: user_authentications; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.user_authentications ENABLE ROW LEVEL SECURITY;

--
-- Name: user_emails; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.user_emails ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: app_public; Owner: -
--

ALTER TABLE app_public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA app_hidden; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA app_hidden TO tasted_visitor;


--
-- Name: SCHEMA app_public; Type: ACL; Schema: -; Owner: -
--

GRANT USAGE ON SCHEMA app_public TO tasted_visitor;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM postgres;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO tasted;
GRANT USAGE ON SCHEMA public TO tasted_visitor;


--
-- Name: FUNCTION assert_valid_password(new_password text); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.assert_valid_password(new_password text) FROM PUBLIC;


--
-- Name: TABLE users; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.users TO tasted_visitor;


--
-- Name: COLUMN users.username; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(username) ON TABLE app_public.users TO tasted_visitor;


--
-- Name: COLUMN users.avatar_url; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(avatar_url) ON TABLE app_public.users TO tasted_visitor;


--
-- Name: COLUMN users.first_name; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(first_name) ON TABLE app_public.users TO tasted_visitor;


--
-- Name: COLUMN users.last_name; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(last_name) ON TABLE app_public.users TO tasted_visitor;


--
-- Name: FUNCTION link_or_register_user(f_user_id uuid, f_service character varying, f_identifier character varying, f_profile json, f_auth_details json); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.link_or_register_user(f_user_id uuid, f_service character varying, f_identifier character varying, f_profile json, f_auth_details json) FROM PUBLIC;


--
-- Name: FUNCTION login(username public.citext, password text); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.login(username public.citext, password text) FROM PUBLIC;


--
-- Name: PROCEDURE migrate_seed(); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON PROCEDURE app_private.migrate_seed() FROM PUBLIC;


--
-- Name: FUNCTION really_create_user(username public.citext, email text, email_is_verified boolean, name text, avatar_url text, password text); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.really_create_user(username public.citext, email text, email_is_verified boolean, name text, avatar_url text, password text) FROM PUBLIC;


--
-- Name: FUNCTION really_create_user(username public.citext, email text, email_is_verified boolean, first_name text, last_name text, avatar_url text, password text); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.really_create_user(username public.citext, email text, email_is_verified boolean, first_name text, last_name text, avatar_url text, password text) FROM PUBLIC;


--
-- Name: FUNCTION register_user(f_service character varying, f_identifier character varying, f_profile json, f_auth_details json, f_email_is_verified boolean); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.register_user(f_service character varying, f_identifier character varying, f_profile json, f_auth_details json, f_email_is_verified boolean) FROM PUBLIC;


--
-- Name: FUNCTION reset_password(user_id uuid, reset_token text, new_password text); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.reset_password(user_id uuid, reset_token text, new_password text) FROM PUBLIC;


--
-- Name: FUNCTION tg__add_audit_job(); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.tg__add_audit_job() FROM PUBLIC;


--
-- Name: FUNCTION tg__add_job(); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.tg__add_job() FROM PUBLIC;


--
-- Name: FUNCTION tg__created(); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.tg__created() FROM PUBLIC;


--
-- Name: FUNCTION tg__timestamps(); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.tg__timestamps() FROM PUBLIC;


--
-- Name: FUNCTION tg_user_email_secrets__insert_with_user_email(); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.tg_user_email_secrets__insert_with_user_email() FROM PUBLIC;


--
-- Name: FUNCTION tg_user_secrets__insert_with_user(); Type: ACL; Schema: app_private; Owner: -
--

REVOKE ALL ON FUNCTION app_private.tg_user_secrets__insert_with_user() FROM PUBLIC;


--
-- Name: FUNCTION accept_friend_request(user_id uuid); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.accept_friend_request(user_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.accept_friend_request(user_id uuid) TO tasted_visitor;


--
-- Name: FUNCTION change_password(old_password text, new_password text); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.change_password(old_password text, new_password text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.change_password(old_password text, new_password text) TO tasted_visitor;


--
-- Name: FUNCTION checkinstatistics(u app_public.users); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.checkinstatistics(u app_public.users) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.checkinstatistics(u app_public.users) TO tasted_visitor;


--
-- Name: FUNCTION confirm_account_deletion(token text); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.confirm_account_deletion(token text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.confirm_account_deletion(token text) TO tasted_visitor;


--
-- Name: TABLE brands; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,DELETE ON TABLE app_public.brands TO tasted_visitor;


--
-- Name: COLUMN brands.name; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(name) ON TABLE app_public.brands TO tasted_visitor;


--
-- Name: COLUMN brands.company_id; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(company_id) ON TABLE app_public.brands TO tasted_visitor;


--
-- Name: COLUMN brands.is_verified; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(is_verified) ON TABLE app_public.brands TO tasted_visitor;


--
-- Name: FUNCTION create_brand(name text, company_id integer); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.create_brand(name text, company_id integer) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.create_brand(name text, company_id integer) TO tasted_visitor;


--
-- Name: TABLE check_ins; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,DELETE ON TABLE app_public.check_ins TO tasted_visitor;


--
-- Name: FUNCTION create_check_in(item_id integer, review text, rating integer, check_in_date date); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.create_check_in(item_id integer, review text, rating integer, check_in_date date) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.create_check_in(item_id integer, review text, rating integer, check_in_date date) TO tasted_visitor;


--
-- Name: FUNCTION create_check_in_comment(target_check_in_id integer, comment text); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.create_check_in_comment(target_check_in_id integer, comment text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.create_check_in_comment(target_check_in_id integer, comment text) TO tasted_visitor;


--
-- Name: TABLE companies; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,DELETE ON TABLE app_public.companies TO tasted_visitor;


--
-- Name: COLUMN companies.name; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(name) ON TABLE app_public.companies TO tasted_visitor;


--
-- Name: COLUMN companies.is_verified; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(is_verified) ON TABLE app_public.companies TO tasted_visitor;


--
-- Name: FUNCTION create_company(company_name text); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.create_company(company_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.create_company(company_name text) TO tasted_visitor;


--
-- Name: FUNCTION create_friend_request(user_id uuid); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.create_friend_request(user_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.create_friend_request(user_id uuid) TO tasted_visitor;


--
-- Name: TABLE items; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,DELETE ON TABLE app_public.items TO tasted_visitor;


--
-- Name: COLUMN items.flavor; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(flavor) ON TABLE app_public.items TO tasted_visitor;


--
-- Name: COLUMN items.description; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(description) ON TABLE app_public.items TO tasted_visitor;


--
-- Name: COLUMN items.type_id; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(type_id) ON TABLE app_public.items TO tasted_visitor;


--
-- Name: COLUMN items.manufacturer_id; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(manufacturer_id) ON TABLE app_public.items TO tasted_visitor;


--
-- Name: COLUMN items.is_verified; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(is_verified) ON TABLE app_public.items TO tasted_visitor;


--
-- Name: COLUMN items.brand_id; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(brand_id) ON TABLE app_public.items TO tasted_visitor;


--
-- Name: FUNCTION create_item(flavor text, type_id integer, brand_id integer, manufacturer_id integer, description text); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.create_item(flavor text, type_id integer, brand_id integer, manufacturer_id integer, description text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.create_item(flavor text, type_id integer, brand_id integer, manufacturer_id integer, description text) TO tasted_visitor;


--
-- Name: FUNCTION current_session_id(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.current_session_id() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.current_session_id() TO tasted_visitor;


--
-- Name: FUNCTION "current_user"(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public."current_user"() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public."current_user"() TO tasted_visitor;


--
-- Name: FUNCTION current_user_friends(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.current_user_friends() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.current_user_friends() TO tasted_visitor;


--
-- Name: FUNCTION current_user_id(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.current_user_id() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.current_user_id() TO tasted_visitor;


--
-- Name: FUNCTION current_user_is_privileged(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.current_user_is_privileged() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.current_user_is_privileged() TO tasted_visitor;


--
-- Name: FUNCTION delete_friend(friend_id uuid); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.delete_friend(friend_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.delete_friend(friend_id uuid) TO tasted_visitor;


--
-- Name: FUNCTION forgot_password(email public.citext); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.forgot_password(email public.citext) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.forgot_password(email public.citext) TO tasted_visitor;


--
-- Name: FUNCTION like_check_in(check_in_id integer); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.like_check_in(check_in_id integer) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.like_check_in(check_in_id integer) TO tasted_visitor;


--
-- Name: FUNCTION logout(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.logout() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.logout() TO tasted_visitor;


--
-- Name: TABLE user_emails; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,DELETE ON TABLE app_public.user_emails TO tasted_visitor;


--
-- Name: COLUMN user_emails.email; Type: ACL; Schema: app_public; Owner: -
--

GRANT INSERT(email) ON TABLE app_public.user_emails TO tasted_visitor;


--
-- Name: FUNCTION make_email_primary(email_id uuid); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.make_email_primary(email_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.make_email_primary(email_id uuid) TO tasted_visitor;


--
-- Name: FUNCTION request_account_deletion(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.request_account_deletion() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.request_account_deletion() TO tasted_visitor;


--
-- Name: FUNCTION resend_email_verification_code(email_id uuid); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.resend_email_verification_code(email_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.resend_email_verification_code(email_id uuid) TO tasted_visitor;


--
-- Name: FUNCTION tg__friend_status(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.tg__friend_status() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.tg__friend_status() TO tasted_visitor;


--
-- Name: FUNCTION tg__graphql_subscription(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.tg__graphql_subscription() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.tg__graphql_subscription() TO tasted_visitor;


--
-- Name: FUNCTION tg_user_emails__forbid_if_verified(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.tg_user_emails__forbid_if_verified() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.tg_user_emails__forbid_if_verified() TO tasted_visitor;


--
-- Name: FUNCTION tg_user_emails__prevent_delete_last_email(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.tg_user_emails__prevent_delete_last_email() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.tg_user_emails__prevent_delete_last_email() TO tasted_visitor;


--
-- Name: FUNCTION tg_user_emails__verify_account_on_verified(); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.tg_user_emails__verify_account_on_verified() FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.tg_user_emails__verify_account_on_verified() TO tasted_visitor;


--
-- Name: FUNCTION users_check_in_statistics(u app_public.users); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.users_check_in_statistics(u app_public.users) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.users_check_in_statistics(u app_public.users) TO tasted_visitor;


--
-- Name: FUNCTION users_has_password(u app_public.users); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.users_has_password(u app_public.users) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.users_has_password(u app_public.users) TO tasted_visitor;


--
-- Name: FUNCTION verify_email(user_email_id uuid, token text); Type: ACL; Schema: app_public; Owner: -
--

REVOKE ALL ON FUNCTION app_public.verify_email(user_email_id uuid, token text) FROM PUBLIC;
GRANT ALL ON FUNCTION app_public.verify_email(user_email_id uuid, token text) TO tasted_visitor;


--
-- Name: TABLE friends; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.friends TO tasted_visitor;


--
-- Name: TABLE activity_feed; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.activity_feed TO tasted_visitor;


--
-- Name: SEQUENCE brands_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.brands_id_seq TO tasted_visitor;


--
-- Name: TABLE categories; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.categories TO tasted_visitor;


--
-- Name: SEQUENCE check_in_comments_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.check_in_comments_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE check_in_likes_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.check_in_likes_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE check_ins_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.check_ins_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE companies_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.companies_id_seq TO tasted_visitor;


--
-- Name: TABLE item_edit_suggestions; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.item_edit_suggestions TO tasted_visitor;


--
-- Name: SEQUENCE item_edit_suggestions_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.item_edit_suggestions_id_seq TO tasted_visitor;


--
-- Name: SEQUENCE items_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.items_id_seq TO tasted_visitor;


--
-- Name: TABLE public_check_ins; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.public_check_ins TO tasted_visitor;


--
-- Name: TABLE user_settings; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.user_settings TO tasted_visitor;


--
-- Name: TABLE public_users; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.public_users TO tasted_visitor;


--
-- Name: TABLE tags; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,DELETE ON TABLE app_public.tags TO tasted_visitor;


--
-- Name: COLUMN tags.name; Type: ACL; Schema: app_public; Owner: -
--

GRANT INSERT(name),UPDATE(name) ON TABLE app_public.tags TO tasted_visitor;


--
-- Name: COLUMN tags.is_verified; Type: ACL; Schema: app_public; Owner: -
--

GRANT UPDATE(is_verified) ON TABLE app_public.tags TO tasted_visitor;


--
-- Name: SEQUENCE tags_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.tags_id_seq TO tasted_visitor;


--
-- Name: TABLE types; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT ON TABLE app_public.types TO tasted_visitor;


--
-- Name: COLUMN types.name; Type: ACL; Schema: app_public; Owner: -
--

GRANT INSERT(name) ON TABLE app_public.types TO tasted_visitor;


--
-- Name: COLUMN types.category; Type: ACL; Schema: app_public; Owner: -
--

GRANT INSERT(category) ON TABLE app_public.types TO tasted_visitor;


--
-- Name: SEQUENCE types_id_seq; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,USAGE ON SEQUENCE app_public.types_id_seq TO tasted_visitor;


--
-- Name: TABLE user_authentications; Type: ACL; Schema: app_public; Owner: -
--

GRANT SELECT,DELETE ON TABLE app_public.user_authentications TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: app_hidden; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_hidden REVOKE ALL ON SEQUENCES  FROM tasted;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_hidden GRANT SELECT,USAGE ON SEQUENCES  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: app_hidden; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_hidden REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_hidden REVOKE ALL ON FUNCTIONS  FROM tasted;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_hidden GRANT ALL ON FUNCTIONS  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: app_public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_public REVOKE ALL ON SEQUENCES  FROM tasted;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_public GRANT SELECT,USAGE ON SEQUENCES  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: app_public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_public REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_public REVOKE ALL ON FUNCTIONS  FROM tasted;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA app_public GRANT ALL ON FUNCTIONS  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA public REVOKE ALL ON SEQUENCES  FROM tasted;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA public GRANT SELECT,USAGE ON SEQUENCES  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA public REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA public REVOKE ALL ON FUNCTIONS  FROM tasted;
ALTER DEFAULT PRIVILEGES FOR ROLE tasted IN SCHEMA public GRANT ALL ON FUNCTIONS  TO tasted_visitor;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE tasted REVOKE ALL ON FUNCTIONS  FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

