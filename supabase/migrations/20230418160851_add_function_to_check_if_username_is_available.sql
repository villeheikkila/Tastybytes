set check_function_bodies = off;

create function fnc__check_if_username_is_available(p_username text) returns void
  language sql
as
$$
begin;
select exists(select 1 from profiles where lower(username) = lower(p_username));
end;
$$;