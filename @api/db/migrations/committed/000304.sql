--! Previous: sha1:28ff8a6010c668acb62b7a3875ccea2fe762df03
--! Hash: sha1:6f9a422737bedb976b1e431cf7ebc7e15caca619

--! split: 1-current.sql
-- Enter migration here
create or replace function app_public.items_current_user_check_ins(i app_public.items)
  returns int
  language sql
  stable
as
$$
select count(*)
from app_public.check_ins
where item_id = i.id and author_id = app_public.current_user_id()
$$;
