--! Previous: sha1:8571b9abbe4b4a5041d95eb1b78139eb512b071b
--! Hash: sha1:c62c955670c7ce67665173245bdc72bbd1637e66

--! split: 1-current.sql
-- Enter migration here
CREATE OR REPLACE FUNCTION app_private.link_or_register_user(f_user_id uuid, f_service character varying, f_identifier character varying, f_profile json, f_auth_details json) RETURNS app_public.users
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
declare
  v_matched_user_id uuid;
  v_matched_authentication_id uuid;
  v_email citext;
  v_name text;
  v_avatar_url text;
  v_user app_public.users;
  v_user_email app_public.user_emails;
begin
  -- See if a user account already matches these details
  select id, user_id
    into v_matched_authentication_id, v_matched_user_id
    from app_public.user_authentications
    where service = f_service
    and identifier = f_identifier
    limit 1;

  if v_matched_user_id is not null and f_user_id is not null and v_matched_user_id <> f_user_id then
    raise exception 'A different user already has this account linked.' using errcode = 'TAKEN';
  end if;

  v_email = f_profile ->> 'email';
  v_name := f_profile ->> 'name';
  v_avatar_url := f_profile ->> 'avatar_url';

  if v_matched_authentication_id is null then
    if f_user_id is not null then
      -- Link new account to logged in user account
      insert into app_public.user_authentications (user_id, service, identifier, details) values
        (f_user_id, f_service, f_identifier, f_profile) returning id, user_id into v_matched_authentication_id, v_matched_user_id;
      insert into app_private.user_authentication_secrets (user_authentication_id, details) values
        (v_matched_authentication_id, f_auth_details);
      perform graphile_worker.add_job(
        'user__audit',
        json_build_object(
          'type', 'linked_account',
          'user_id', f_user_id,
          'extra1', f_service,
          'extra2', f_identifier,
          'current_user_id', app_public.current_user_id()
        ));
    elsif v_email is not null then
      -- See if the email is registered
      select * into v_user_email from app_public.user_emails where email = v_email and is_verified is true;
      if v_user_email is not null then
        -- User exists!
        insert into app_public.user_authentications (user_id, service, identifier, details) values
          (v_user_email.user_id, f_service, f_identifier, f_profile) returning id, user_id into v_matched_authentication_id, v_matched_user_id;
        insert into app_private.user_authentication_secrets (user_authentication_id, details) values
          (v_matched_authentication_id, f_auth_details);
        perform graphile_worker.add_job(
          'user__audit',
          json_build_object(
            'type', 'linked_account',
            'user_id', f_user_id,
            'extra1', f_service,
            'extra2', f_identifier,
            'current_user_id', app_public.current_user_id()
          ));
      end if;
    end if;
  end if;
  if v_matched_user_id is null and f_user_id is null and v_matched_authentication_id is null then
    -- Create and return a new user account
    return app_private.register_user(f_service, f_identifier, f_profile, f_auth_details, true);
  else
    if v_matched_authentication_id is not null then
      update app_public.user_authentications
        set details = f_profile
        where id = v_matched_authentication_id;
      update app_private.user_authentication_secrets
        set details = f_auth_details
        where user_authentication_id = v_matched_authentication_id;
      update app_public.users
        set
          name = coalesce(users.name, v_name),
          avatar_url = coalesce(users.avatar_url, v_avatar_url)
        where id = v_matched_user_id
        returning  * into v_user;
      return v_user;
    else
      -- v_matched_authentication_id is null
      -- -> v_matched_user_id is null (they're paired)
      -- -> f_user_id is not null (because the if clause above)
      -- -> v_matched_authentication_id is not null (because of the separate if block above creating a user_authentications)
      -- -> contradiction.
      raise exception 'This should not occur';
    end if;
  end if;
end;
$$;
