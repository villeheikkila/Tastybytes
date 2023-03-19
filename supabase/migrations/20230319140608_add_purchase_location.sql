alter table "public"."check_ins" add column "purchase_location_id" uuid;

alter table "public"."check_ins" add constraint "check_ins_purchase_location_id_fkey" FOREIGN KEY (purchase_location_id) REFERENCES locations(id) ON DELETE SET NULL not valid;

alter table "public"."check_ins" validate constraint "check_ins_purchase_location_id_fkey";

CREATE OR REPLACE FUNCTION public.fnc__search_products(p_search_term text, p_only_non_checked_in boolean, p_category_name text DEFAULT NULL::text, p_subcategory_id bigint DEFAULT NULL::bigint)
 RETURNS SETOF materialized_view__search_product_ratings
 LANGUAGE sql
AS $function$
select pr.*
from view__search_product_ratings pr
       left join categories cat on pr.category_id = cat.id
       left join products_subcategories psc on psc.product_id = pr.id and psc.subcategory_id = p_subcategory_id
where (p_category_name is null or cat.name = p_category_name)
  and (p_subcategory_id is null or psc.subcategory_id is not null)
  and (p_only_non_checked_in is false or pr.current_user_check_ins = 0)
  and (pr.search_value @@ to_tsquery(replace(p_search_term, ' ', ' & ') || ':*'))
order by ts_rank(search_value, to_tsquery(replace(p_search_term, ' ', ' & ') || ':*')) desc;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__set_product_logo_on_upload()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if new.bucket_id = 'product-logos' then
    update
      public.products
    set logo_file = new.name
    where id = split_part(new.name, '_', 1)::bigint;
  end if;
  return new;
end;
$function$
;


