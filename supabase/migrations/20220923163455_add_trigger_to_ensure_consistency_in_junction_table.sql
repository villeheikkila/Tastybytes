CREATE UNIQUE INDEX unique_product_subcategory ON public.products_subcategories USING btree (product_id, subcategory_id);

alter table "public"."products_subcategories" add constraint "unique_product_subcategory" UNIQUE using index "unique_product_subcategory";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__check_subcategory_constraint()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare
    is_allowed boolean := false;
begin
    select (select category_id from subcategories sc where sc.id = new.subcategory_id)
               = (select category_id from products p where p.id = new.product_id)
    into is_allowed;

    if is_allowed = false
    then
        raise exception 'Product has different category than the subcategory';
    end if;
    return new;
end;
$function$
;

CREATE TRIGGER check_subcategory_constraint AFTER INSERT OR UPDATE ON public.products_subcategories FOR EACH ROW EXECUTE FUNCTION tg__check_subcategory_constraint();


