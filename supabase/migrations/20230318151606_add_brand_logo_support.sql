drop index if exists "public"."unique_products";

CREATE UNIQUE INDEX unique_products ON public.products USING btree (lower((name)::text), description, category_id, sub_brand_id);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__set_brand_logo_on_upload()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if new.bucket_id = 'brand-logos' then
    update
      public.brands
    set logo_file = new.name
    where id = split_part(new.name, '_', 1)::bigint;
  end if;
  return new;
end;
$function$
;

alter table "storage"."objects" drop constraint "objects_owner_fkey";

alter table "storage"."objects" add constraint "objects_owner_fkey" FOREIGN KEY (owner) REFERENCES auth.users(id) not valid;

alter table "storage"."objects" validate constraint "objects_owner_fkey";

CREATE TRIGGER on_brand_logo_upload BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION tg__set_brand_logo_on_upload();


