--! Previous: sha1:0a560d360e39378d0a3c7d9e718503ab55ed3c51
--! Hash: sha1:8501284b7f92dadb3913c0c999e618cd886abcbe

--! split: 1-current.sql
-- Enter migration here
create trigger _500_gql_update
  after update
  on app_public.friends
  for each row
execute procedure app_public.tg__graphql_subscription(
  'friendRequestChange',
  'graphql:user:$1',
  'id'
  );
