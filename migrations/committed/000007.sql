--! Previous: sha1:29df89b73f1cfeaff19f6e4c621cf1400a2ba744
--! Hash: sha1:c19bdc88aaac4f3464de6e5aa7dc6758fff991b4

-- Enter migration here
create table tasted_public.brands (
  id serial primary key,
  name tasted_public.short_text,
  company_id integer references tasted_public.companies(id) on delete cascade,
  unique (company_id, name)
);
