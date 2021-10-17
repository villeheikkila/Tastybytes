--! Previous: sha1:da87e6b5fad4eff76782d4df59f54c3c58dfb3e5
--! Hash: sha1:0097f4ed308bab2a82b6e6edaa48938dfbd89597

--! split: 1-current.sql
-- Enter migration here
create table app_public.categories (name varchar(40) primary key);
create table app_public.types (
  id serial primary key,
  name text not null,
  category text not null references app_public.categories(name),
  unique (name, category)
);
comment on table app_public.categories is 'Main categories for items';
create table app_public.companies (
  id serial primary key,
  name text not null unique,
  is_verified boolean default false not null,
  created_at timestamp with time zone default now() not null,
  created_by uuid references app_public.users(id),
  CONSTRAINT companies_name_check CHECK (
    (length(name) >= 2)
    AND (length(name) <= 24)
  )
);
comment on table app_public.types is 'Type item that is part of a category';
create table app_public.tags (
  id serial primary key,
  name text unique,
  CONSTRAINT tag_name_check CHECK (
    (length(name) >= 2)
    AND (length(name) <= 10)
  )
);
comment on table app_public.tags is 'Tag for an item or check-in';
create table app_public.locations (
  id uuid primary key,
  name text not null,
  latitude decimal,
  longitude decimal,
  CONSTRAINT locations_name_check CHECK (
    (length(name) >= 2)
    AND (length(name) <= 24)
  )
);
comment on table app_public.locations is 'Contains locations for check ins';
create table app_public.items (
  id serial primary key,
  brand text not null,
  flavor text,
  description text,
  type_id integer not null references app_public.types(id),
  manufacturer integer not null references app_public.companies(id),
  is_verified boolean default false,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  created_by uuid references app_public.users(id),
  updated_by uuid references app_public.users(id),
  CONSTRAINT items_brand_check CHECK (
    (length(brand) >= 2)
    AND (length(brand) <= 24)
  ),
  CONSTRAINT items_flavor_check CHECK (
    (length(flavor) >= 2)
    AND (length(flavor) <= 24)
  ),
  CONSTRAINT items_description_check CHECK (
    (length(description) >= 2)
    AND (length(description) <= 512)
  ),
  unique(brand, flavor, manufacturer)
);
comment on table app_public.items is 'Item defines a product that can be rated';
create table app_public.check_ins (
  id serial primary key,
  rating integer,
  review text,
  item_id integer not null references app_public.items(id),
  author uuid not null references app_public.users(id),
  check_in_date date,
  location uuid references app_public.locations(id),
  is_public boolean default true,
  created_at timestamp with time zone default now() not null,
  CONSTRAINT check_ins_review_check CHECK (
    (length(review) >= 1)
    AND (length(review) <= 1024)
  ),
  CONSTRAINT check_ins_rating CHECK (
    rating >= 0
    AND rating <= 10
  )
);
comment on table app_public.check_ins is 'Check-in is a review given to an item';
CREATE TABLE app_public.items_tags (
  item_id integer references items(id),
  tag_id integer references tags(id),
  primary key (item_id, tag_id)
);
comment on table app_public.items_tags is 'Junction table between an item and a tag';
