--! Previous: sha1:e6c42d434282b7130c5c634ab4911d6a0dbbd444
--! Hash: sha1:cf46185fd1304571d740132706d36bcf936ccdf5

--! split: 1-current.sql
-- Enter migration here
grant
   select
on app_public.category to :DATABASE_VISITOR
