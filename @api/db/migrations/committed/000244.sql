--! Previous: sha1:949a20b6f5ce0bd38e625bb1896b81503dca5c12
--! Hash: sha1:1759d0c4dd472848126ed9df5cd15c81d28d7538

--! split: 1-current.sql
-- enter migration here
create or replace function app_private.assert_valid_password(new_password text) returns void
  language plpgsql
as
$$
begin
  if (select new_password ~ '[0-9\.]+$' = false) then
    raise exception 'password must contain numbers' using errcode = 'weakp';
  end if;
  if (select new_password ~ '[a-z]+$' = false) then
    raise exception 'password must contain letters' using errcode = 'weakp';
  end if;
  if length(new_password) <= 8 then
    raise exception 'password must be at least 8 characters long' using errcode = 'weakp';
  end if;
end;
$$;
