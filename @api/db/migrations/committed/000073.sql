--! Previous: sha1:17a95fd338ee7e60e87f00c176d2c4788ac14111
--! Hash: sha1:d4582dae9c0b5b5d6805369d2b83cff5a2f2ef3b

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is
  E'@foreignKey (id) references check_ins(id)|@fieldName id';
