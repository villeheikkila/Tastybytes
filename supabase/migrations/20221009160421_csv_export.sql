set check_function_bodies = off;

create or replace view "public"."csv_export" as  WITH agg_products AS (
         SELECT cat.name AS category,
            string_agg(sc.name, ', '::text ORDER BY sc.name) AS subcategory,
            bo.name AS brand_owner,
            b.name AS brand,
            s.name AS "sub-brand",
            p.name,
            p.id
           FROM ((((((products p
             LEFT JOIN "sub-brands" s ON ((p."sub-brand_id" = s.id)))
             LEFT JOIN brands b ON ((s.brand_id = b.id)))
             LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
             LEFT JOIN categories cat ON ((p.category_id = cat.id)))
             LEFT JOIN products_subcategories ps ON ((ps.product_id = p.id)))
             LEFT JOIN subcategories sc ON ((ps.subcategory_id = sc.id)))
          GROUP BY cat.name, bo.name, b.name, p.name, s.name, p.description, p.id
        )
 SELECT pr.id,
    ap.category,
    ap.subcategory,
    m.name AS manufacturer,
    ap.brand_owner,
    ap.brand,
    ap."sub-brand",
    ap.name,
    string_agg(c.review, ', '::text) AS reviews,
    string_agg((((c.rating)::double precision / (2)::double precision))::text, ', '::text) AS ratings,
    pr.username
   FROM (((check_ins c
     LEFT JOIN agg_products ap ON ((ap.id = c.product_id)))
     LEFT JOIN companies m ON ((c.manufacturer_id = m.id)))
     LEFT JOIN profiles pr ON ((c.created_by = pr.id)))
  GROUP BY pr.id, pr.username, ap.category, ap.subcategory, m.name, ap.brand_owner, ap.brand, ap."sub-brand", ap.name, ap.id;


CREATE OR REPLACE FUNCTION public.fnc__export_data()
 RETURNS SETOF csv_export
 LANGUAGE plpgsql
AS $function$
begin
    return query (select * from csv_export
                  where id = auth.uid());
end;
$function$
;


