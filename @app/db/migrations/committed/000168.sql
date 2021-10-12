--! Previous: sha1:15d9aeeb36d1feb4a587d216c81072ed988beebf
--! Hash: sha1:ce71a7f1c73d4e0f0278ff76ea89d707497b2da6

--! split: 1-current.sql
-- Enter migration here
create table check_in_friends (
  check_in_id int references app_public.check_ins(id) on delete cascade ,
  friend_id uuid references app_public.users(id) on delete cascade
)
