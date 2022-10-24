--! Previous: sha1:04196a6c8d480bf54c238e1c882c3b472a162850
--! Hash: sha1:e97d1fe9eec577a8af44ac1003941c8232c51df2

--! split: 1-current.sql
-- Enter migration here
drop trigger _500_gql_insert on app_public.friends;

create trigger _500_gql_insert
  after insert
  on app_public.friends
  for each row
execute procedure app_public.tg__graphql_subscription(
  'friendRequestChange',
  'graphql:user:$1',
  'user_id_2'
  );
