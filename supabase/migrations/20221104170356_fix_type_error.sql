set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__export_data()
 RETURNS TABLE(id uuid, category text, subcategory text, manufacturer text, brand_owner text, brand text, sub_brand text, name text, reviews text, ratings text, username text)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN query (WITH agg_products AS (SELECT cat.name                                         AS category,
                                             string_agg(sc.name, ', '::text ORDER BY sc.name) AS subcategory,
                                             bo.name                                          AS brand_owner,
                                             b.name                                           AS brand,
                                             s.name                                           AS sub_brand,
                                             p.name,
                                             p.id
                                      FROM ((((((products p
                                        LEFT JOIN sub_brands s ON ((p.sub_brand_id = s.id)))
                                        LEFT JOIN brands b ON ((s.brand_id = b.id)))
                                        LEFT JOIN companies bo ON ((b.brand_owner_id = bo.id)))
                                        LEFT JOIN categories cat ON ((p.category_id = cat.id)))
                                        LEFT JOIN products_subcategories ps ON ((ps.product_id = p.id)))
                                        LEFT JOIN subcategories sc ON ((ps.subcategory_id = sc.id)))
                                      GROUP BY cat.name,
                                               bo.name,
                                               b.name,
                                               p.name,
                                               s.name,
                                               p.description,
                                               p.id)
                SELECT pr.id,
                       ap.category::text,
                       ap.subcategory::text,
                       m.name::text                           AS manufacturer,
                       ap.brand_owner::text,
                       ap.brand::text,
                       ap.sub_brand::text,
                       ap.name::text,
                       string_agg(c.review, ', '::text) AS reviews,
                       string_agg((((c.rating)::double precision / (2)::double precision))::text,
                                  ', '::text)           AS ratings,
                       pr.username::text
                FROM ((((check_ins c
                  LEFT JOIN agg_products ap ON ((ap.id = c.product_id)))
                  LEFT JOIN product_variants pv ON ((pv.id = c.product_variant_id)))
                  LEFT JOIN companies m ON ((pv.manufacturer_id = m.id)))
                  LEFT JOIN profiles pr ON ((c.created_by = pr.id)))
                WHERE c.created_by = auth.uid()
                GROUP BY pr.id,
                         pr.username,
                         ap.category,
                         ap.subcategory,
                         m.name,
                         ap.brand_owner,
                         ap.brand,
                         ap.sub_brand,
                         ap.name,
                         ap.id);
END;
$function$
;


