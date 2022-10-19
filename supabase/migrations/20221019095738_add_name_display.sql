create type "public"."enum__name_display" as enum ('full_name', 'username');

alter table "public"."profiles" add column "name_display" enum__name_display default 'username'::enum__name_display;


