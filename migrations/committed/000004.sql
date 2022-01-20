--! Previous: sha1:9c02a64ff95a26708e23fdcc487f91ea9bd0a6d3
--! Hash: sha1:4d20113e4550cdeb1ceb55b0516e3e0b8abb9331

-- Enter migration here
create table tasted_public.categories (name varchar(40) primary key);

create table tasted_public.types (
  id serial primary key,
  name text not null,
  category text not null references tasted_public.categories(name) on delete cascade,
  unique (name, category)
);
