alter table "public"."profiles" add column "fts" tsvector generated always as (to_tsvector('english'::regconfig, ((((username || ' '::text) || first_name) || ' '::text) || last_name))) stored;

CREATE INDEX profiles_fts ON public.profiles USING gin (fts);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_friends()
 RETURNS SETOF profiles
 LANGUAGE sql
AS $function$
with friend_ids as (select CASE
                               WHEN user_id_1 != auth.uid()
                                   THEN user_id_1
                               ELSE user_id_2 END friend_id
                    from friends
                    where status = 'accepted'
                      and (user_id_1 = auth.uid() or user_id_2 = auth.uid()))
select p.*
from friend_ids f
         left join profiles p on p.id = f.friend_id
$function$
;

CREATE OR REPLACE FUNCTION public.trigger_check_friend_status_transition()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
    if old.status = 'pending' and new.status = 'blocked' then
        new.blocked_by = auth.uid();
    elseif
        new.status = 'accepted' then
        new.blocked_by = null and new.accepted_at = now();
    elseif old.status in ('accepted', 'blocked') and
           new.status = 'pending' then
        raise exception 'friend status cannot be changed back to pending';
    end if;
    return new;
end;
$function$
;

CREATE TRIGGER on_friend_request_update AFTER INSERT OR UPDATE ON public.friends FOR EACH ROW EXECUTE FUNCTION trigger_check_friend_status_transition();


