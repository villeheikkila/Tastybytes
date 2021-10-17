--! Previous: sha1:77c44264409f91e38b90626d2b3a80e07690bf67
--! Hash: sha1:5f7fe6bc21dc956c7c8f0257e85ef126cec7467a

--! split: 1-current.sql
-- Enter migration here
alter table app_public.tags add column created_by uuid references app_public.users(id) on delete set null;
alter table app_public.tags add column created_at timestamp with time zone DEFAULT now() NOT NULL;
alter table app_public.tags add column is_verified boolean default false not null;
