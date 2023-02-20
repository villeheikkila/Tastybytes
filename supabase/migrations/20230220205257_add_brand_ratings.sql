create or replace view "public"."view__brand_ratings" as  SELECT b.id,
    b.name,
    b.brand_owner_id,
    b.created_at,
    b.created_by,
    b.is_verified,
    b.logo_file,
    count(ci.id) AS total_check_ins,
    round(avg((ci.rating)::numeric), 2) AS average_rating,
    count(ci.id) FILTER (WHERE (ci.created_by IN ( SELECT view__current_user_friends.id
           FROM view__current_user_friends))) AS friends_check_ins,
    round(avg((ci.rating)::numeric) FILTER (WHERE (ci.created_by IN ( SELECT view__current_user_friends.id
           FROM view__current_user_friends))), 2) AS friends_average_rating,
    count(ci.id) FILTER (WHERE (ci.created_by = auth.uid())) AS current_user_check_ins,
    round(avg((ci.rating)::numeric) FILTER (WHERE (ci.created_by = auth.uid())), 2) AS current_user_average_rating
   FROM (((brands b
     LEFT JOIN sub_brands sb ON ((b.id = sb.brand_id)))
     LEFT JOIN products p ON ((p.sub_brand_id = sb.id)))
     LEFT JOIN check_ins ci ON ((p.id = ci.product_id)))
  GROUP BY b.id;



