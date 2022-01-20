--! Previous: sha1:0d7380e96dd567119666aaf19551df76a6f86e09
--! Hash: sha1:b87e3470dfa465f56370c3c0a9518be570ab7b3b

-- Enter migration here
drop table tasted_public.products;

create table tasted_public.products (
  id serial primary key,
  name tasted_public.short_text,
  brand_id integer not null references tasted_public.brands(id) on delete cascade,
  description tasted_public.long_text,
  type_id integer not null references tasted_public.types(id) on delete cascade,
  is_verified boolean default false,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  created_by uuid references tasted_public.users(id) on delete set null,
  updated_by uuid references tasted_public.users(id) on delete set null,
  unique(name, brand_id, type_id)
);
