--! Previous: sha1:845371994c014e1870b288b94e5ce631f23c43c8
--! Hash: sha1:17a95fd338ee7e60e87f00c176d2c4788ac14111

--! split: 1-current.sql
-- Enter migration here
comment on view app_public.public_check_ins is E'@name offers
@uniqueKey id
@foreignKey (id) references app_public.check_ins';
