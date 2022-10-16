set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__check_friend_status_transition()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.status = 'blocked' then
    new.blocked_by = auth.uid();
  elseif
    new.status = 'accepted' then
    if old.blocked_by is not null and old.blocked_by != auth.uid() then
      raise exception 'blocked user can`t unblock themselves';
    elseif new.user_id_1 != auth.uid() then
      new.accepted_at = now();
      new.blocked_by = null and new.accepted_at = now();
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


