--! Previous: sha1:44d7c88ae9991959c7508b03652f5b01ecfc76da
--! Hash: sha1:f59f80aa130123707f494be8dac77c3804cb25f6

-- Enter migration here
create or replace function tasted_private.assert_valid_password(new_password text) returns void
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
