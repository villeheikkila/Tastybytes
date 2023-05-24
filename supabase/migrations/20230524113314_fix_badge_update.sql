create or replace function tg__send_push_notification() returns trigger
  security definer
  SET search_path = public
  language plpgsql
as
$$
declare
  v_notification                    jsonb;
  v_device_tokens                   text[];
  v_push_notification_device_tokens text[];
  v_current_device_token            text;
begin

  select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
  select array_agg(firebase_registration_token)
  from profile_push_notifications
  where created_by = new.profile_id
  into v_device_tokens;

  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_friend_request_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_reaction_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  elseif new.tagged_in_check_in_id is not null then
    select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
    select array_agg(firebase_registration_token)
    from profile_push_notifications
    where send_tagged_check_in_notifications = true
      and created_by = new.profile_id
    into v_push_notification_device_tokens;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
  end if;

  if array_length(v_device_tokens, 1) is null or array_length(v_device_tokens, 1) = 0 then
    return new;
  else
    foreach v_current_device_token in array v_device_tokens
      loop
        perform fnc__post_request(url, headers, body)
        from fnc__get_push_notification_request(v_current_device_token, jsonb_build_object('apns', json_build_object('payload', json_build_object('aps', jsonb_build_object(
                                                                                                             'badge',
                                                                                                             fnc__get_badge_count_aps(new.profile_id))))));
      end loop;
  end if;

  if array_length(v_push_notification_device_tokens, 1) is null or
     array_length(v_push_notification_device_tokens, 1) = 0 then
    return new;
  else
    foreach v_current_device_token in array v_push_notification_device_tokens
      loop
        perform fnc__post_request(url, headers, body)
        from fnc__get_push_notification_request(v_current_device_token, v_notification);
      end loop;
  end if;


  return new;
end;
$$;

