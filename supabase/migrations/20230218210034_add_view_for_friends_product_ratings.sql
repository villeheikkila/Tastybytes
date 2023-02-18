drop view if exists "public"."product_user_ratings";

create or replace view "public"."view__current_user_friends" as  SELECT
        CASE
            WHEN (friends.user_id_1 = auth.uid()) THEN friends.user_id_2
            ELSE friends.user_id_1
        END AS id
   FROM friends
  WHERE (((friends.user_id_1 = auth.uid()) OR (friends.user_id_2 = auth.uid())) AND (friends.status = 'accepted'::enum__friend_status));


create or replace view "public"."view__product_ratings" as  SELECT p.id,
    p.name,
    p.description,
    p.created_at,
    p.created_by,
    p.category_id,
    p.sub_brand_id,
    p.is_verified,
    count(ci.id) AS total_check_ins,
    round(avg((ci.rating)::numeric), 2) AS average_rating,
    count(ci.id) FILTER (WHERE (ci.created_by IN ( SELECT view__current_user_friends.id
           FROM view__current_user_friends))) AS friends_check_ins,
    round(avg((ci.rating)::numeric) FILTER (WHERE (ci.created_by IN ( SELECT view__current_user_friends.id
           FROM view__current_user_friends))), 2) AS friends_average_rating,
    count(ci.id) FILTER (WHERE (ci.created_by = auth.uid())) AS current_user_check_ins,
    round(avg((ci.rating)::numeric) FILTER (WHERE (ci.created_by = auth.uid())), 2) AS current_user_average_rating
   FROM (products p
     LEFT JOIN check_ins ci ON ((p.id = ci.product_id)))
  GROUP BY p.id;



