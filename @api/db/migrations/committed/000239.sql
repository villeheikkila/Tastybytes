--! Previous: sha1:6c21cae0a30dca603ae6a95585b5127ec742810e
--! Hash: sha1:71584d393550a74b0c8e80d76a7e3c40d4f6b68d

--! split: 1-current.sql
-- Enter migration here
create or replace function app_private.really_create_user(username public.citext, email text, email_is_verified boolean, name text,
                                               avatar_url text,
                                               password text default null::text) returns app_public.users
  language plpgsql
  set search_path to 'pg_catalog', 'public', 'pg_temp'
as
$$
declare
  v_user     app_public.users;
  v_username citext = username;
begin
  if password is not null then
    perform app_private.assert_valid_password(password);
  end if;
  if email is null then
    raise exception 'email is required' using errcode = 'modat';
  end if;

  insert into app_public.users (username, name, avatar_url)
  values (v_username, name, avatar_url)
  returning * into v_user;

  insert into app_public.user_emails (user_id, email, is_verified, is_primary)
  values (v_user.id, email, email_is_verified, email_is_verified);

  insert into app_public.user_settings (id)
  values (v_user.id);

  if password is not null then
    update app_private.user_secrets
    set password_hash = crypt(password, gen_salt('bf'))
    where user_id = v_user.id;
  end if;

  select * into v_user from app_public.users where id = v_user.id;

  return v_user;
end;
$$;
