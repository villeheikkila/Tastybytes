--! Previous: sha1:d229a88bd207c7eaf45b0e20e8c440ff33ca51c3
--! Hash: sha1:d5169253c8b16172e726fce58825c3f4ed421641

--! split: 1-current.sql
-- Enter migration here
create table app_public.brands (
  id serial primary key,
  name text,
  company_id integer references app_public.companies(id),
  unique (company_id, name),
  CONSTRAINT brands_name_check CHECK (
    (length(name) >= 2)
    AND (length(name) <= 56)
  )
);
alter table app_public.items drop column brand;
alter table app_public.items
add column brand_id integer references app_public.brands(id) on delete cascade;
