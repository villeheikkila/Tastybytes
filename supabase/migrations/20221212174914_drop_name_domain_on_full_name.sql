alter table profiles
    drop column preferred_name;

alter table profiles
    drop column search;

alter table "public"."profiles" alter column "first_name" set data type text using "first_name"::text;

alter table "public"."profiles" alter column "last_name" set data type text using "last_name"::text;

alter table public.profiles
  add search text generated always as (username || COALESCE(first_name, ''::text) ||
                                        COALESCE(last_name, '')) stored;

alter table public.profiles
  add preferred_name text generated always as (
    CASE
      WHEN (name_display = 'full_name'::enum__name_display)
        THEN (first_name || ' ' || last_name)
      ELSE username
      END) stored;

