--! Previous: sha1:4b7cf5158928c941a82c10cf88da9de8b9ab0400
--! Hash: sha1:9c02a64ff95a26708e23fdcc487f91ea9bd0a6d3

-- Enter migration here
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;

CREATE DOMAIN tasted_public.short_text AS text
	CONSTRAINT short_text_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 56)));

CREATE TABLE tasted_public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    username public.citext NOT NULL,
    first_name tasted_public.short_text,
    last_name tasted_public.short_text,
    is_admin boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
