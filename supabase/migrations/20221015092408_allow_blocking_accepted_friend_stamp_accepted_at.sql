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
        new.accepted_at = now();
        new.blocked_by = null and new.accepted_at = now();
    elseif old.status in ('accepted', 'blocked') and
           new.status = 'pending' then
        raise exception 'friend status cannot be changed back to pending';
    end if;
    return new;
end;
$function$
;


