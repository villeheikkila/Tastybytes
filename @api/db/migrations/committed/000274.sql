--! Previous: sha1:ef4922dee3fb235aa06b3c2624c56cf8bc0350c3
--! Hash: sha1:32e33266f77535f8c894db327b19c8af0db59ea4

--! split: 1-current.sql
create function app_public.search_users(search text)
  returns setof app_public.users as $$
    select *
    from app_public.users
    where
      username ilike ('%' || search || '%') or
      concat(first_name, ' ', last_name) ilike ('%' || search || '%')
  $$ language sql stable;
