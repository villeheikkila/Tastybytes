--! Previous: sha1:6f9a422737bedb976b1e431cf7ebc7e15caca619
--! Hash: sha1:3b08cd6a17f2e61562f848e21a17dc589dc6d98f

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.items_total_check_ins(i app_public.items)
  returns int
  language sql
  stable
as
$$
select count(1)
from app_public.check_ins
where item_id = i.id
$$;

create or replace function app_public.items_current_user_check_ins(i app_public.items)
  returns int
  language sql
  stable
as
$$
select count(1)
from app_public.check_ins
where item_id = i.id and author_id = app_public.current_user_id()
$$;

create or replace function app_public.items_check_ins_past_month(i app_public.items)
  returns int
  language sql
  stable
as
$$
select count(1)
from app_public.check_ins
where item_id = i.id and created_at >= current_date - interval '1 month';
$$;
