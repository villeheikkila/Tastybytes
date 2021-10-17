--! Previous: sha1:d4215b27bf906850ac03aaae90d091b45b8b3bf7
--! Hash: sha1:811cab95472a3124dec97c228d41e122557bd7ef

--! split: 1-current.sql
-- Enter migration here
drop table app_public.items_tags;

create table check_in_tags (
  check_in_id int references app_public.check_ins(id),
  tag_id int references app_public.tags(id),
  primary key (check_in_id, tag_id)
)
