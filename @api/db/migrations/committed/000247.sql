--! Previous: sha1:bfe7f5083209879dcc142198ee667089f0eec998
--! Hash: sha1:0a560d360e39378d0a3c7d9e718503ab55ed3c51

--! split: 1-current.sql
-- enter migration here
create function app_public.tg__updated() returns trigger
  language plpgsql
  set search_path to 'pg_cata'
as
$$
begin
  new.updated_by = app_public.current_user_id();
  new.updated_at = now();
  return new;
end;
$$;

create trigger _100_updated_by
  before update
  on app_public.items
  for each row
execute function app_public.tg__updated();
