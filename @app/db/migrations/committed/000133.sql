--! Previous: sha1:cb9f9e3693f95d1fca68cddf99d20d20f142af01
--! Hash: sha1:331ebb9e56bdb4a369c7647bf6962ee1aeedc1b7

--! split: 1-current.sql
create domain long_text as text check (length(value) >= 0 and length(value) <= 1024);

create table app_public.check_in_comments
(
  id          serial primary key,
  check_in_id integer not null references app_public.check_ins (id) on delete cascade,
  created_by  uuid    not null references app_public.users (id) on delete cascade,
  comment long_text
)
