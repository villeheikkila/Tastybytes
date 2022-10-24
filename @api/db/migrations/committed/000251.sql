--! Previous: sha1:41b690134689ba2439c4084d144b5ecf42920bef
--! Hash: sha1:1661903e333132c45ab205b7108ea7805a643c7f

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
  'user_id_2 as id'
  );
