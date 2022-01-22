--! Previous: sha1:42ed72de2253642c18058d47bcfe82b3618362fd
--! Hash: sha1:44d7c88ae9991959c7508b03652f5b01ecfc76da

-- Enter migration here
create function tasted_public.login(username citext, password text) returns tasted_public.users as
$$
declare
  v_user tasted_public.users;
  v_user_secret tasted_private.user_secrets;
begin
  select users.*
  into v_user
  from tasted_public.users
  where users.username = login.username;

  if not (v_user is null) then
    select *
    into v_user_secret
    from tasted_private.user_secrets
    where user_secrets.user_id = v_user.id;

    if v_user_secret.password_hash = crypt(password, v_user_secret.password_hash) then
      return v_user;
    else
      return null;
    end if;
  else
    return null;
  end if;
end;
$$ language plpgsql strict
                    volatile;
