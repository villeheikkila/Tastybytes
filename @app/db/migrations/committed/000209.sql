--! Previous: sha1:546e98977050fdf62a028a4bef8053532694f0b6
--! Hash: sha1:ce38805da6df5e81c976a70bbe355e19619a5d7a

--! split: 1-current.sql
-- Enter migration here
create type app_private.role as enum (
  'user',
  'moderator',
  'admin');

alter table app_private.user_secrets
  add column role app_private.role default 'user';
