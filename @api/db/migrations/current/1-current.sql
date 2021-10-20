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
