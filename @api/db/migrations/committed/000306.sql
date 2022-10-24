--! Previous: sha1:3b08cd6a17f2e61562f848e21a17dc589dc6d98f
--! Hash: sha1:c6faa8e4785163215916c975be44828071c93a2f

--! split: 1-current.sql
drop function app_public.checkinstatistics(u app_public.users);
drop function app_public.users_check_in_statistics(u app_public.users);

create function app_public.users_total_check_ins(u app_public.users)
  returns int
  language sql
  stable
as
$$
select count(1)
from app_public.check_ins
where author_id = u.id;
$$;

create function app_public.users_unique_check_ins(u app_public.users)
  returns int
  language sql
  stable
as
$$
select count(distinct item_id)
from app_public.check_ins
where author_id = u.id;
$$;
