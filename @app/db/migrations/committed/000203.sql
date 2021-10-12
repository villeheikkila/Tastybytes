--! Previous: sha1:f75281014b06a756e46901d8490e51ed8ba2ca65
--! Hash: sha1:81919f693a6a90086fffb1adf2cf637e6c1850fe

--! split: 1-current.sql
-- Enter migration here
drop function add_check_in_comment(target_check_in_id integer, comment text);

create function create_check_in_comment(target_check_in_id integer, comment text) returns app_public.check_in_comments
  security definer
  SET search_path = pg_catalog, public, pg_temp
  language plpgsql
as
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

grant execute on function create_check_in_comment(integer, text) to tasted_visitor;
