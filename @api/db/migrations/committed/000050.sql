--! Previous: sha1:6954279d4c92f3054390dd40f1cf19789070343d
--! Hash: sha1:96e0cf99aeb85779a160a36d710d9a03754378b3

--! split: 1-current.sql
-- Enter migration here
CREATE TABLE app_public.user_settings (
  id uuid primary key,
  public_check_ins boolean,
  foreign key (id) references app_public.users(id)
)
