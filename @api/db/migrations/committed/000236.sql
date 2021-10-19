--! Previous: sha1:9797eed1ca340c7b35ba13b5748fce947d890860
--! Hash: sha1:a1e8d9f9f4ce7090b7c95b1d7ca677db68e9c6ac

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.tg__friend_status() returns trigger as
$$
begin
  if old.status = 'blocked' and
     new.status = 'accepted' then
    new.blocked_by = null;
  elseif old.status in ('accepted', 'blocked') and
         new.status = 'pending' then
    raise exception 'friend status cannot be changed back to pending';
  end if;
  return new;
end;
$$ language plpgsql;


create trigger check_friendship_status
  before update
  on app_public.friends
  for each row
execute procedure app_public.tg__friend_status();
