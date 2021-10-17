--! Previous: sha1:27fb580dde7f886d5f348980f0f44034be99317c
--! Hash: sha1:4d87579d8e4be332c812b35e30a5bc7eba42cbb8

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (id) references app_public.check_ins(id)';
