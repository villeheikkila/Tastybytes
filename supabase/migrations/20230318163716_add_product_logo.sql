alter table "public"."products" add column "logo_file" text;

set check_function_bodies = off;

create function tg__set_product_logo_on_upload() returns trigger
  SET search_path = public
  security definer
  language plpgsql
as
$$
begin
  if new.bucket_id = 'product-logos' then
    update
      public.products
    set logo_file = new.name
    where id = split_part(new.name, '_', 1)::bigint;
  end if;
  return new;
end;
$$;

CREATE TRIGGER on_product_logo_upload AFTER INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION tg__set_product_logo_on_upload();


