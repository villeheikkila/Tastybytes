--! Previous: sha1:24bd74fa6178cb60095357f2eae8333ceffea02f
--! Hash: sha1:bfe7f5083209879dcc142198ee667089f0eec998

--! split: 1-current.sql
-- enter migration here
create or replace function app_private.assert_valid_password(new_password text) returns void
  language plpgsql
as
$$
begin
  if (select new_password ~ '\d' = false) then
    raise exception 'password must contain numbers' using errcode = 'WEAKP';
  end if;
  if (select new_password ~ '[a-zA-Z]' = false) then
    raise exception 'password must contain letters' using errcode = 'WEAKP';
  end if;
  if length(new_password) <= 8 then
    raise exception 'password must be at least 8 characters long' using errcode = 'WEAKP';
  end if;
end;
$$;
