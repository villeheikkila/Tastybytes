--! Previous: sha1:9bd27aeecda2507c8d66ad98087df6f2e3312cca
--! Hash: sha1:64d1575d10ba270a9f8a437778ea08e27a7166b9

-- Enter migration here
create or replace function tasted_public.register(
  username citext,
  password text default null
) returns tasted_public.users as
$$
declare
  v_user     tasted_public.users;
  v_username citext = username;
begin
  perform tasted_private.assert_valid_password(password);
  insert into tasted_public.users (username)
  values (v_username, name)
  returning * into v_user;

  if password is not null then
    update tasted_private.user_secrets
    set password_hash = crypt(password, gen_salt('bf'))
    where user_id = v_user.id;
  end if;

  select * into v_user from tasted_public.users where id = v_user.id;
  return v_user;
end;
$$ language plpgsql stable
                    set search_path to pg_catalog, public, pg_temp;
