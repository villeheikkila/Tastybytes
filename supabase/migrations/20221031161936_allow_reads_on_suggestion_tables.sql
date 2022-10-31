set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__export_data()
 RETURNS SETOF csv_export
 LANGUAGE plpgsql
AS $function$
BEGIN
   RETURN query (
      SELECT
         *
      FROM csv_export
      WHERE
         id = auth.uid ());
END;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__forbid_changing_check_in_id()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  new.check_in_id = old.check_in_id;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__friend_request_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  -- make sure that the sender is the current user and that the profiles can't be updated later
  new.user_id_1 = (case when TG_OP = 'INSERT' then auth.uid() else old.user_id_1 end);
  new.user_id_2 = (case when TG_OP = 'INSERT' then new.user_id_2 else old.user_id_2 end);
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__is_verified_check()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if fnc__has_permission(auth.uid(), 'can_verify') is false then
    new.is_verified = (case
                         when TG_OP = 'INSERT' then false
                         else old.is_verified end);
  else
    -- Everything created by an user that can verify is created as verified
    new.is_verified = (case
                         when TG_OP = 'INSERT' then true
                         else (case when new.is_verified is null then old.is_verified else new.is_verified end) end);
  end if;

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__must_be_friends()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
DECLARE
  v_friend_id bigint;
begin
  select id
  from friends
  where (user_id_1 = auth.uid() and user_id_2 = new.profile_id)
     or (user_id_1 = new.profile_id and user_id_2 = auth.uid())
  into v_friend_id;

  if v_friend_id is null then
    raise exception 'included profile must be a friend' using errcode = 'not_in_friends';
  else
    return new;
  end if;
end;
$function$
;

create policy "Enable read access for all users"
on "public"."brand_edit_suggestions"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."brands"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."company_edit_suggestions"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."product_edit_suggestion_subcategories"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."product_edit_suggestions"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."sub_brand_edit_suggestion"
as permissive
for select
to public
using (true);



