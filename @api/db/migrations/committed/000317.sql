--! Previous: sha1:90a0ff5f746d14897b41851cf15de16862a12329
--! Hash: sha1:fb54c3432bbc7e7ec02feb1839483b2cc0d3c91f

--! split: 1-current.sql
-- Enter migration here
create function app_public.stamp_liked_by() returns trigger as
$$
begin
  NEW.liked_by = app_public.current_user_id();
  return NEW;
end;
$$ language plpgsql volatile
                    set search_path to pg_catalog, public, pg_temp;


create trigger stamp_liked_by_for_company_likes
  before insert
  on app_public.company_likes
  for each row
execute procedure app_public.stamp_liked_by();
