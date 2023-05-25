set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.fnc__get_subcategory_stats(p_user_id uuid, p_category_id bigint)
 RETURNS TABLE(id bigint, name text, count integer)
 LANGUAGE sql
AS $function$
with unique_products as (select distinct ci.product_id
                         from check_ins ci
                                left join products p on ci.product_id = p.id
                         where ci.created_by = p_user_id and category_id = p_category_id
                         group by ci.product_id),
     stats as (select sc.id, sc.name, count(up.product_id)
               from subcategories sc
                      left join products_subcategories ps on ps.subcategory_id = sc.id
                      left join unique_products up on up.product_id = ps.product_id
               group by sc.id, sc.name)
select *
from stats
where count > 0
order by count desc;
$function$
;


alter table "storage"."objects" drop constraint "objects_owner_fkey";

alter table "storage"."objects" add constraint "objects_owner_fkey" FOREIGN KEY (owner) REFERENCES auth.users(id) ON DELETE SET NULL not valid;

alter table "storage"."objects" validate constraint "objects_owner_fkey";

create policy "Allow adding logos for users with permissions 1y64xqi_0"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'logos'::text) AND (storage.extension(name) = 'jpeg'::text) AND fnc__has_permission(auth.uid(), 'can_add_product_logo'::text)));


create policy "Allow insert for users with permission 15kep2a_0"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'brand-logos'::text) AND (storage.extension(name) = 'jpeg'::text) AND fnc__has_permission(auth.uid(), 'can_add_brand_logo'::text)));


create policy "Allow upload for users with permission 1y64xqi_0"
on "storage"."objects"
as permissive
for insert
to public
with check (((bucket_id = 'product-logos'::text) AND (storage.extension(name) = 'jpeg'::text) AND fnc__has_permission(auth.uid(), 'can_add_product_logo'::text)));



