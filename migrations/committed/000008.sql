--! Previous: sha1:c19bdc88aaac4f3464de6e5aa7dc6758fff991b4
--! Hash: sha1:0d7380e96dd567119666aaf19551df76a6f86e09

-- Enter migration here
CREATE DOMAIN tasted_public.long_text AS text
	CONSTRAINT long_text_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 56)));

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
  unique(name, brand_id)
);


alter table tasted_public.companies
  drop constraint companies_created_by_fkey;

alter table tasted_public.companies
  add constraint companies_created_by_fkey
    foreign key (created_by) references tasted_public.users
      on delete set null;
