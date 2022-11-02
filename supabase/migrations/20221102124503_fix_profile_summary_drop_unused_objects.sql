drop function if exists "public"."fnc__get_profile_summary"(p_uid uuid);

drop type "public"."reactions";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_profile_summary(p_uid uuid)
 RETURNS TABLE(total_check_ins bigint, unique_check_ins bigint, average_rating numeric, unrated bigint, rating_1 bigint, rating_2 bigint, rating_3 bigint, rating_4 bigint, rating_5 bigint, rating_6 bigint, rating_7 bigint, rating_8 bigint, rating_9 bigint, rating_10 bigint)
 LANGUAGE plpgsql
AS $function$
begin
  return query (select count(1)                                               total_check_ins,
                       count(distinct product_id)                             unique_check_ins,
                       round(avg(rating), 2)                                  average_rating,
                       count(1) filter ( where rating is null )               unrated,
                       count(1) filter ( where rating <= 0.5 )                rating_1,
                       count(1) filter ( where rating > 0.5 and rating <= 1 ) rating_2,
                       count(1) filter ( where rating > 1 and rating <= 1.5 ) rating_3,
                       count(1) filter ( where rating > 1.5 and rating <= 2 ) rating_4,
                       count(1) filter ( where rating > 2 and rating <= 2.5 ) rating_5,
                       count(1) filter ( where rating > 2.5 and rating <= 3 ) rating_6,
                       count(1) filter ( where rating > 3 and rating <= 3.5 ) rating_7,
                       count(1) filter ( where rating > 3.5 and rating <= 4 ) rating_8,
                       count(1) filter ( where rating > 4 and rating <= 4.5 ) rating_9,
                       count(1) filter ( where rating > 4.5 and rating <= 5 ) rating_10
                from check_ins
                where created_by = p_uid);
end ;
$function$
;


