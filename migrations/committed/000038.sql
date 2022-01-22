--! Previous: sha1:13854b2219fc7dff4f90cf3c53ded85477483400
--! Hash: sha1:51e00e3c2305b359f878b71827a1b30398a3a484

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
  values (v_username)
  returning * into v_user;
  insert into tasted_private.user_secrets (user_id, password_hash)
  values (v_user.id, crypt(password, gen_salt('bf')));

  select * into v_user from tasted_public.users where id = v_user.id;
  return v_user;
end;
$$ language plpgsql strict
                    volatile;
