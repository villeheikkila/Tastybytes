--! Previous: sha1:770e98b491623e6da570ddeedb7e9053988cc690
--! Hash: sha1:ba1b1ddc336704502035f7acafb8ee3e36c17451

--! split: 1-current.sql
-- Enter migration here
create table app_public.item_edit_suggestions
(
  id              serial primary key,
  description     long_text,
  flavor          short_text,
  created_at      timestamp with time zone default now()                     not null,
  item_id         integer references app_public.items (id) on delete cascade not null,
  manufacturer_id int references app_public.companies (id) on delete cascade,
  brand_id        int references app_public.brands (id) on delete cascade    not null,
  author_id       uuid references app_public.users (id) on delete cascade    not null,
  accepted timestamp with time zone
)
