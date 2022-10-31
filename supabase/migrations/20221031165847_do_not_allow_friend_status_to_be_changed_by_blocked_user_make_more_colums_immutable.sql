drop trigger if exists "forbid_moving_comment_to_different_check_in" on "public"."check_in_comments";

drop policy "Enable update for the creaotr" on "public"."check_ins";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__stamp_created_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.created_at = (case when TG_OP = 'INSERT' then now() else old.created_at end);
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__check_friend_status_transition()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if old.blocked_by is not null and old.blocked_by != auth.uid() then
    raise exception 'blocked user can´t update the friend relation' using errcode = 'blocked';
  end if;
  
  if new.status = 'blocked' then
    new.blocked_by = auth.uid();
  elseif
    new.status = 'accepted' then
    if new.user_id_1 != auth.uid() then
      new.accepted_at = now();
      new.blocked_by = null;
    else
      raise exception 'sender of the friend request can`t accept the friend request';
    end if;
  elseif old.status in ('accepted', 'blocked') and
         new.status = 'pending' then
    raise exception 'friend status cannot be changed back to pending';
  end if;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__friend_request_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_already_exists bool := false;
begin
  select exists(select 1
                from friends f
                where (f.user_id_1 = new.user_id_1 and f.user_id_1 = new.user_id_2)
                   or (f.user_id_1 = new.user_id_2 and f.user_id_1 = new.user_id_1));
  if v_already_exists then
    raise exception 'users are already friends with each other' using errcode = 'already_friends';
  end if;

  -- make sure that the sender is the current user and that the profiles can't be updated later
  new.user_id_1 = (case when TG_OP = 'INSERT' then auth.uid() else old.user_id_1 end);
  new.user_id_2 = (case when TG_OP = 'INSERT' then new.user_id_2 else old.user_id_2 end);
  return new;
end;
$function$
;

create policy "Enable update for the creator"
on "public"."check_ins"
as permissive
for update
to public
using ((created_by = auth.uid()));


CREATE TRIGGER make_check_in_id_immutable BEFORE UPDATE ON public.check_in_comments FOR EACH ROW EXECUTE FUNCTION tg__forbid_changing_check_in_id();

CREATE TRIGGER stamp_created_at BEFORE INSERT OR UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_at();


