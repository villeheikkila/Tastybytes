alter table public.profiles
  drop column preferred_name;

alter table public.profiles
  add preferred_name text generated always as (
    case
      when (name_display = 'full_name'::enum__name_display and first_name is not null and last_name is not null)
        then ((first_name || ' '::text) || last_name)
      else (username)::text
      end) stored;
