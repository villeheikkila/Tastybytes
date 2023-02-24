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
    round(avg((ci.rating)::numeric) FILTER (WHERE (ci.created_by = auth.uid())), 2) AS current_user_average_rating,
    count(ci.id) FILTER (WHERE (ci.created_at > (now() - '1 mon'::interval))) AS check_ins_during_previous_month
   FROM (products p
     LEFT JOIN check_ins ci ON ((p.id = ci.product_id)))
  GROUP BY p.id;




