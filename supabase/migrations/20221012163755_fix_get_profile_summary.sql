drop function if exists "public"."fnc__get_profile_summary"(uid uuid);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_profile_summary(p_uid uuid)
 RETURNS TABLE("totalCheckIns" bigint, "totalUnique" bigint, "averageRating" numeric)
 LANGUAGE plpgsql
AS $function$
begin
  return query (select count(1)                                 "total_check_ins",
                       count(distinct product_id)               "unique_check_ins",
                       round(avg(rating), 2)                    "average_rating",
                       count(1) filter ( where rating is null ) "unrated",
                       count(1) filter ( where rating = 0 )     "rating_0",
                       count(1) filter ( where rating = 1 )     "rating_1",
                       count(1) filter ( where rating = 2 )     "rating_2",
                       count(1) filter ( where rating = 3 )     "rating_3",
                       count(1) filter ( where rating = 4 )     "rating_4",
                       count(1) filter ( where rating = 5 )     "rating_5",
                       count(1) filter ( where rating = 6 )     "rating_6",
                       count(1) filter ( where rating = 7 )     "rating_7",
                       count(1) filter ( where rating = 8 )     "rating_8",
                       count(1) filter ( where rating = 9 )     "rating_9",
                       count(1) filter ( where rating = 10 )     "rating_10"
                from check_ins
                where created_by = p_uid);
end;
$function$
;


