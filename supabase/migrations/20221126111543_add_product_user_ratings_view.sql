create or replace view "public"."product_user_ratings" as  SELECT ci.product_id,
    round(avg((ci.rating)::numeric), 2) AS rating
   FROM (check_ins ci
     LEFT JOIN products p ON ((ci.product_id = p.id)))
  GROUP BY ci.product_id, ci.created_by;



