alter table "auth"."users" add column "deleted_at" timestamp with time zone;

alter table "auth"."users" alter column "phone" set data type text using "phone"::text;

alter table "auth"."users" alter column "phone_change" set data type text using "phone_change"::text;

CREATE INDEX refresh_token_session_id ON auth.refresh_tokens USING btree (session_id);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION auth.email()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.email', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
	)::text
$function$
;

CREATE OR REPLACE FUNCTION auth.role()
 RETURNS text
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.role', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
	)::text
$function$
;

CREATE OR REPLACE FUNCTION auth.uid()
 RETURNS uuid
 LANGUAGE sql
 STABLE
AS $function$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.sub', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
	)::uuid
$function$
;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION tg__create_profile_for_new_user();


drop policy "Enable update for the owner" on "public"."profile_settings";

drop policy "Users can update own profile." on "public"."profiles";

drop view if exists "public"."view__profile_product_ratings";

CREATE UNIQUE INDEX locations_name_longitude_latitude_country_code_key1 ON public.locations USING btree (name, longitude, latitude, country_code);

alter table "public"."locations" add constraint "locations_name_longitude_latitude_country_code_key1" UNIQUE using index "locations_name_longitude_latitude_country_code_key1";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__search_products_ng(p_search_term text, p_only_non_checked_in boolean, p_category_name text DEFAULT NULL::text, p_subcategory_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF view__product_ratings
 LANGUAGE sql
AS $function$
select p.*
from view__product_ratings p
       left join categories cat on p.category_id = cat.id
       left join products_subcategories psc on psc.product_id = p.id and psc.subcategory_id = p_subcategory_id
       left join "sub_brands" sb on sb.id = p."sub_brand_id"
       left join brands b on sb.brand_id = b.id
       left join companies c on b.brand_owner_id = c.id
where (p_category_name is null or cat.name = p_category_name)
  and (p_subcategory_id is null or psc.subcategory_id is not null)
  and (p_only_non_checked_in is false or p.current_user_check_ins = 0)
  and (p_search_term % b.name
  or p_search_term % sb.name
  or p_search_term % p.name
  or p_search_term % p.description)
order by ((similarity(p_search_term, b.name) * 2 + similarity(p_search_term, sb.name) +
           similarity(p_search_term, p.name)) + similarity(p_search_term, p.description) / 2) desc;
$function$
;

create materialized view "public"."materialized_view_product_search" as  SELECT p.id,
    to_tsvector(((((COALESCE((b.name)::text, ''::text) || ' '::text) || COALESCE((sb.name)::text, ''::text)) || ' '::text) || COALESCE((p.name)::text, ''::text))) AS search_value
   FROM ((view__product_ratings p
     LEFT JOIN sub_brands sb ON ((sb.id = p.sub_brand_id)))
     LEFT JOIN brands b ON ((sb.brand_id = b.id)));


CREATE OR REPLACE FUNCTION public.fnc__get_current_profile()
 RETURNS profiles
 LANGUAGE sql
AS $function$
select * from profiles where id = auth.uid() limit 1;
$function$
;

CREATE OR REPLACE FUNCTION public.fnc__search_products(p_search_term text, p_only_non_checked_in boolean, p_category_name text DEFAULT NULL::text, p_subcategory_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF view__product_ratings
 LANGUAGE sql
AS $function$
select pr.*
from materialized_view_product_search ps
       left join view__product_ratings pr on ps.id = pr.id
       left join categories cat on pr.category_id = cat.id
       left join products_subcategories psc on psc.product_id = pr.id and psc.subcategory_id = p_subcategory_id
       left join "sub_brands" sb on sb.id = pr."sub_brand_id"
       left join brands b on sb.brand_id = b.id
       left join companies c on b.brand_owner_id = c.id
where (p_category_name is null or cat.name = p_category_name)
  and (p_subcategory_id is null or psc.subcategory_id is not null)
  and (p_only_non_checked_in is false or pr.current_user_check_ins = 0)
  and (ps.search_value @@ to_tsquery(replace(p_search_term, ' ', ' & ') || ':*'))
ORDER BY ts_rank(search_value, to_tsquery(replace(p_search_term, ' ', ' & ') || ':*')) DESC;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__clean_up_check_in()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
  declare
    v_trimmed_review text;
begin
  -- minimum rating is 0.25, 0 is used to mark the check-in not having a rating
  if new.rating < 0.25 then
    new.rating = null;
  end if;

  select trim(regexp_replace(new.review, E'[\\n\\r\\u2028]+', ' ', 'g' )) into v_trimmed_review;

  if new.review is null or length(v_trimmed_review) = 0 then
    new.review = null;
  else
    new.review = v_trimmed_review;
  end if;

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__send_push_notification()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
declare
  v_notification jsonb;
begin
  if new.friend_request_id is not null then
    select fnc__get_friend_request_notification(new.friend_request_id) into v_notification;
  elseif new.check_in_reaction_id is not null then
    select fnc__get_check_in_reaction_notification(new.check_in_reaction_id) into v_notification;
  elseif new.tagged_in_check_in_id is not null then
    select fnc__get_check_in_tag_notification(new.tagged_in_check_in_id) into v_notification;
  else
    select jsonb_build_object('notification', jsonb_build_object('title', '', 'body', new.message)) into v_notification;
  end if;

  perform fnc__post_request(url, headers, body)
  from fnc__get_push_notification_request(new.profile_id,
                                          v_notification);

  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__set_avatar_on_upload()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if new.bucket_id = 'avatars' then
    delete from storage.objects where bucket_id = 'avatars' and owner = new.owner;
    with parts as (select string_to_array(new.name, '/') arr),
         formatted_parts as (select array_to_string(arr[2:], '')                              image_url,
                                    substr(array_to_string(arr[2:], ''), 0,
                                           strpos(array_to_string(arr[2:], ''), '.'))::bigint check_in_id
                             from parts)
    update
      public.profiles
    set avatar_file = fp.image_url
    from formatted_parts fp
    where id = new.owner;
  end if;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__set_check_in_image_on_upload()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if new.bucket_id = 'check-ins' then
    with parts as (select string_to_array(new.name, '/') arr),
         formatted_parts as (select array_to_string(arr[2:], '')                      image_url,
                                    substr(array_to_string(arr[2:], ''), 0,
                                           strpos(array_to_string(arr[2:], ''), '.'))::bigint check_in_id
                             from parts)
    update
      check_ins
    set image_file = fp.image_url
    from formatted_parts fp
    where created_by = new.owner
      and id = fp.check_in_id;
  end if;
  return new;
end;
$function$
;

create or replace view "public"."view__profile_product_ratings" as  SELECT p.id,
    p.name,
    p.description,
    p.created_at,
    p.created_by,
    p.category_id,
    p.sub_brand_id,
    p.is_verified,
    ci.created_by AS check_in_created_by,
    count(p.id) AS check_ins,
    round(avg((ci.rating)::numeric), 2) AS average_rating
   FROM ((products p
     LEFT JOIN check_ins ci ON ((p.id = ci.product_id)))
     LEFT JOIN profiles pr ON ((ci.created_by = pr.id)))
  GROUP BY p.id, pr.id, ci.created_by;


create policy "Enable delete for users with permission"
on "public"."flavors"
as permissive
for delete
to authenticated
using (fnc__has_permission(auth.uid(), 'can_delete_flavors'::text));


create policy "Enable insert for users with permission"
on "public"."flavors"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_insert_flavors'::text));


create policy "Enable update for users with permission"
on "public"."flavors"
as permissive
for update
to authenticated
using (fnc__has_permission(auth.uid(), 'can_update_flavors'::text));


create policy "Enable insert for users with permission"
on "public"."products_subcategories"
as permissive
for insert
to authenticated
with check (fnc__has_permission(auth.uid(), 'can_add_subcategories'::text));


create policy "Enable update for owner"
on "public"."profile_settings"
as permissive
for update
to public
using ((id = auth.uid()))
with check ((id = auth.uid()));


create policy "Enable update for users with permission"
on "public"."sub_brands"
as permissive
for update
to authenticated
using (fnc__has_permission(auth.uid(), 'can_update_sub_brands'::text));


create policy "Users can update own profile."
on "public"."profiles"
as permissive
for update
to authenticated
using ((auth.uid() = id))
with check ((auth.uid() = id));



alter table "storage"."objects" drop constraint "objects_owner_fkey";

alter table "storage"."buckets" add column "allowed_mime_types" text[];

alter table "storage"."buckets" add column "avif_autodetection" boolean default false;

alter table "storage"."buckets" add column "file_size_limit" bigint;

alter table "storage"."objects" add constraint "objects_owner_fkey" FOREIGN KEY (owner) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "storage"."objects" validate constraint "objects_owner_fkey";

create policy "Allow deleting own avatar"
on "storage"."objects"
as permissive
for delete
to public
using ((auth.uid() = owner));


create policy "Allow updating own avatar"
on "storage"."objects"
as permissive
for update
to public
using ((auth.uid() = owner));


create policy "Give anon users access to JPG images in folder 1oj01fe_0"
on "storage"."objects"
as permissive
for select
to public
using (((bucket_id = 'avatars'::text) AND (storage.extension(name) = 'jpeg'::text) AND (lower((storage.foldername(name))[1]) = 'public'::text) AND (auth.role() = 'anon'::text)));


create policy "Give users access to own folder 1oj01fe_0"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Give users access to own folder 1oj01fe_1"
on "storage"."objects"
as permissive
for update
to public
using (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Give users access to own folder 1oj01fe_2"
on "storage"."objects"
as permissive
for delete
to public
using (((bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Give users access to own folder 6km4rt_0"
on "storage"."objects"
as permissive
for update
to public
using (((bucket_id = 'check-ins'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Give users access to own folder 6km4rt_1"
on "storage"."objects"
as permissive
for delete
to public
using (((bucket_id = 'check-ins'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Give users access to own folder 6km4rt_2"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'check-ins'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Give users access to own folder 6km4rt_3"
on "storage"."objects"
as permissive
for select
to public
using (((bucket_id = 'check-ins'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));


create policy "Public Access"
on "storage"."objects"
as permissive
for select
to public
using ((bucket_id = 'public'::text));


CREATE TRIGGER on_avatar_upload BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION tg__set_avatar_on_upload();

CREATE TRIGGER on_check_in_image_upload AFTER INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION tg__set_check_in_image_on_upload();


