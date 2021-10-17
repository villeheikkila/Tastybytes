--! Previous: sha1:eba29fcd0d20c16c32f13fb0fe57b0866af44f6c
--! Hash: sha1:72853f756a10a54a9168fa1e59ca65d8884c1be7

--! split: 1-current.sql
-- Enter migration here
DROP VIEW app_public.public_users;
drop table app_public.friend_requests;
drop view app_public.activity_feed;
drop function app_public.delete_friend(friend_id uuid);
drop function app_public.delete_friend_request(user_id uuid);
drop function app_public.create_friend_request(receiver_id uuid);
drop type app_public.friend_status;
drop table app_public.friends;

drop function app_public.add_check_in_comment(target_check_in_id integer, comment text);
create type friend_status as enum (
  'accepted',
  'pending'
  );

create table app_public.friends
(
  user_id_1 uuid           not null references app_public.users (id),
  user_id_2 uuid           not null references app_public.users (id),
  status    friend_status not null default 'pending',
  sent      date          not null default now(),
  accepted  date,
  primary key (user_id_1, user_id_2),
  check (user_id_1 <> user_id_2)
);

create or replace function app_public.add_check_in_comment(target_check_in_id integer, comment text) RETURNS app_public.check_in_comments
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS
$$
declare
  v_check_in_exists boolean;
  v_too_often       boolean;
  v_are_friends     boolean;
  v_current_user    uuid;
  v_check_in_id     integer;
  v_comment         app_public.check_in_comments;
begin
  v_current_user := app_public.current_user_id();
  v_check_in_id := target_check_in_id;

  if v_current_user is null then
    raise exception 'You must log in to add a comment' using errcode = 'LOGIN';
  end if;

  select exists(select 1 from app_public.check_ins where id = v_check_in_id)
  into v_check_in_exists;

  if v_check_in_exists is false then
    raise exception 'No such check in exists' using errcode = 'INVAL';
  end if;

  select exists(select 1
                from app_public.check_in_comments c
                       left join app_public.check_ins ci on ci.id = c.check_in_id
                       left join app_public.friends f on ci.author_id = f.user_id_2
                where f.user_id_1 = v_current_user)
  into v_are_friends;

  if v_are_friends is false then
    raise exception 'You need to be friends to comment on a check in' using errcode = 'INVAL';
  end if;

  select exists(select 1
                from app_public.check_in_comments c
                where c.check_in_id = v_check_in_id
                  and c.created_at > NOW() - INTERVAL '1 minutes')
  into v_too_often;

  if v_too_often is true then
    raise exception 'You can only comment on same check in once in one minute' using errcode = 'LIMIT';
  end if;

  insert into app_public.check_in_comments (created_by, check_in_id, comment)
  values (v_current_user, check_in_id, comment)
  returning * into v_comment;

  return v_comment;
end;
$$;


CREATE OR REPLACE VIEW app_public.public_users AS
WITH public_users AS (
  SELECT u.*
  FROM app_public.users u
         LEFT JOIN app_public.user_settings s ON u.id = s.id
  WHERE s.is_public = TRUE
)
SELECT p.*,
       f.status
FROM public_users p
       LEFT JOIN app_public.friends f ON (f.user_id_1 = current_user_id()
  AND p.id = f.user_id_2) OR (f.user_id_1 = p.id AND f.user_id_1 = current_user_id())
WHERE p.id != current_user_id();

create or replace view app_public.activity_feed as
select app_public.check_ins.*
from app_public.check_ins
       left join
     app_public.friends on
           app_public.check_ins.author_id = app_public.friends.user_id_2 or
           app_public.check_ins.author_id = app_public.friends.user_id_1
order by app_public.check_ins.created_at;


create or replace function app_public.create_friend_request(user_id uuid) RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS
$$
declare
  v_request_exists boolean;
  v_current_user   uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to create a friend request' using errcode = 'LOGIN';
  end if;

  select exists(select 1
                from app_public.friends
                where (user_id_1 = v_current_user and user_id_2 = user_id)
                   or (user_id_1 = user_id and user_id_2 = v_current_user))
  into v_request_exists;

  if v_request_exists is true then
    raise exception 'Friend request already exists' using errcode = 'INVAL';
  end if;

  insert into app_public.friends (user_id_1, user_id_2) values (v_current_user, user_id);
end;
$$;

create function app_public.delete_friend(friend_id uuid) RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
  SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS
$$
declare
  v_is_friends   boolean;
  v_current_user uuid;
begin
  v_current_user := app_public.current_user_id();

  if v_current_user is null then
    raise exception 'You must log in to remove a friend request or friendship' using errcode = 'LOGIN';
  end if;

  select exists(select 1
                from app_public.friends
                where (user_id_1 = v_current_user and user_id_2 = friend_id)
                   or (user_id_2 = v_current_user and user_id_1 = friend_id))
  into v_is_friends;

  if v_is_friends is false then
    raise exception 'There is no such friend relation' using errcode = 'INVAL';
  end if;

  delete
  from app_public.friends
  where (user_id_1 = v_current_user and user_id_2 = friend_id)
     or (user_id_2 = v_current_user and user_id_1 = friend_id);
end;
$$;
