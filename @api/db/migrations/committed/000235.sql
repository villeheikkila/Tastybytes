--! Previous: sha1:3ab5292aaa1d19b062acd6a4e1aab0feab4d0136
--! Hash: sha1:9797eed1ca340c7b35ba13b5748fce947d890860

--! split: 1-current.sql
-- Enter migration here
alter table app_public.friends add column blocked_by uuid references app_public.users(id) on delete cascade;
