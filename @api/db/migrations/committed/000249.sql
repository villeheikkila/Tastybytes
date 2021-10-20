--! Previous: sha1:8501284b7f92dadb3913c0c999e618cd886abcbe
--! Hash: sha1:d78017f1cda53477d9882ca8ae50db164fb3e4c3

--! split: 1-current.sql
-- Enter migration here
create trigger _500_gql_insert
  after insert
  on app_public.friends
  for each row
execute procedure app_public.tg__graphql_subscription(
  'friendRequestChange',
  'graphql:user:$1',
  'id'
  );
