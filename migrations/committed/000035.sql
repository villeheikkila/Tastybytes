--! Previous: sha1:9494ca1483ff2eae4b2bbb3fed5b7e49d4669e84
--! Hash: sha1:7fc0fcc2ffd4a57e4864d9d5670df4b537e56bee

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
$$ language plpgsql strict
                    volatile;
