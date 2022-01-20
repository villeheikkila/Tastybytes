--! Previous: sha1:4d20113e4550cdeb1ceb55b0516e3e0b8abb9331
--! Hash: sha1:3b6e4def49634386777535a5e6a04a7a19a7d57c

-- Enter migration here
drop table tasted_public.users;

create table tasted_public.users (
  id uuid primary key default gen_random_uuid(),
  username citext not null unique check(length(username) >= 2 and length(username) <= 24 and username ~ '^[a-zA-Z]([_]?[a-zA-Z0-9])+$'),
  name text,
  is_admin boolean not null default false,
  is_verified boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table tasted_public.companies (
  id serial primary key,
  name text not null unique,
  first_name tasted_public.short_text,
  last_name tasted_public.short_text,
  is_verified boolean default false not null,
  created_at timestamp with time zone default now() not null,
  created_by uuid references tasted_public.users(id),
  CONSTRAINT companies_name_check CHECK (
    (length(name) >= 2)
    AND (length(name) <= 24)
  )
);
