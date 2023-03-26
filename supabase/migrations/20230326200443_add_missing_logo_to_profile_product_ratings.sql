drop view if exists "public"."view__profile_product_ratings";

create or replace view "public"."view__profile_product_ratings" as  SELECT p.id,
    p.name,
    p.description,
    p.created_at,
    p.created_by,
    p.category_id,
    p.sub_brand_id,
    p.is_verified,
    p.logo_file,
    ci.created_by AS check_in_created_by,
    count(p.id) AS check_ins,
    round(avg((ci.rating)::numeric), 2) AS average_rating
   FROM ((products p
     LEFT JOIN check_ins ci ON ((p.id = ci.product_id)))
     LEFT JOIN profiles pr ON ((ci.created_by = pr.id)))
  GROUP BY p.id, pr.id, ci.created_by;



