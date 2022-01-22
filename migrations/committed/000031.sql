--! Previous: sha1:f59f80aa130123707f494be8dac77c3804cb25f6
--! Hash: sha1:dcca597c6f1ed85dc84f73854149504155627717

-- Enter migration here
create function tasted_private.really_create_user(
  username citext,
  password text default null
) returns tasted_public.users as
$$
declare
  v_user     tasted_public.users;
  v_username citext = username;
begin
  if password is not null then
    perform tasted_private.assert_valid_password(password);
  end if;

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
$$ language plpgsql volatile
                    set search_path to pg_catalog, public, pg_temp;
