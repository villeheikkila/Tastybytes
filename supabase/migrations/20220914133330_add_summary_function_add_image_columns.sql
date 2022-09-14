alter table "public"."check_ins" add column "image_url" text;

alter table "public"."profiles" add column "avatar_url" text;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_profile_summary(uid uuid)
 RETURNS TABLE("totalCheckIns" bigint, "totalUnique" bigint, "averageRating" numeric)
 LANGUAGE plpgsql
AS $function$
begin
    return query (select count(1) "totalCheckIns", count(distinct product_id) "totalUnique", round(avg(rating) / 2, 2) "averageRating"
    from check_ins
    where created_by = uid);
end;
$function$
;

create policy "Public Access"
on "storage"."objects"
as permissive
for select
to public
using ((bucket_id = 'public'::text));



