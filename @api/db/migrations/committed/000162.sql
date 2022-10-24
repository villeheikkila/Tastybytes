--! Previous: sha1:88efbd99a4406feead3dd887546a264db773ad35
--! Hash: sha1:77c44264409f91e38b90626d2b3a80e07690bf67

--! split: 1-current.sql
-- Enter migration here
alter table app_public.check_in_tags
  drop constraint check_in_tags_check_in_id_fkey;

alter table app_public.check_in_tags
  add constraint check_in_tags_check_in_id_fkey
    foreign key (check_in_id) references app_public.check_ins
      on delete cascade;

alter table app_public.check_in_tags
  drop constraint check_in_tags_tag_id_fkey;

alter table app_public.check_in_tags
  add constraint check_in_tags_tag_id_fkey
    foreign key (tag_id) references app_public.tags
      on delete cascade;


alter table app_public.check_ins
  drop constraint check_ins_item_id_fkey;

alter table app_public.check_ins
  add constraint check_ins_item_id_fkey
    foreign key (item_id) references app_public.items
      on delete cascade;

alter table app_public.check_ins
  drop constraint check_ins_author_fkey;

alter table app_public.check_ins
  add constraint check_ins_author_fkey
    foreign key (author_id) references app_public.users
      on delete cascade;

alter table app_public.check_ins
  drop constraint check_ins_location_fkey;

alter table app_public.check_ins
  add constraint check_ins_location_fkey
    foreign key (location) references app_public.locations
      on delete set null;

alter table app_public.companies
  drop constraint companies_created_by_fkey;

alter table app_public.companies
  add constraint companies_created_by_fkey
    foreign key (created_by) references app_public.users
      on delete set null;

alter table app_public.items
  drop constraint items_type_id_fkey;

alter table app_public.items
  add constraint items_type_id_fkey
    foreign key (type_id) references app_public.types
      on delete cascade;

alter table app_public.items
  drop constraint items_manufacturer_fkey;

alter table app_public.items
  add constraint items_manufacturer_fkey
    foreign key (manufacturer_id) references app_public.companies
      on delete cascade;

alter table app_public.items
  drop constraint items_created_by_fkey;

alter table app_public.items
  add constraint items_created_by_fkey
    foreign key (created_by) references app_public.users
      on delete set null;

alter table app_public.items
  drop constraint items_updated_by_fkey;

alter table app_public.items
  add constraint items_updated_by_fkey
    foreign key (updated_by) references app_public.users
      on delete set null;

alter table app_public.types
  drop constraint types_category_fkey;

alter table app_public.types
  add constraint types_category_fkey
    foreign key (category) references app_public.categories
      on delete cascade;

alter table app_public.user_settings
  drop constraint user_settings_id_fkey;

alter table app_public.user_settings
  add constraint user_settings_id_fkey
    foreign key (id) references app_public.users
      on delete cascade;
