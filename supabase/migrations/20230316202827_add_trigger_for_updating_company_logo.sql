CREATE OR REPLACE FUNCTION public.tg__set_company_logo_on_upload()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'public'
AS $function$
begin
  if new.bucket_id = 'logos' then
    update
      public.companies
    set logo_file = new.name
    where id = split_part(new.name, '_', 1)::bigint;
  end if;
  return new;
end;
$function$
;

DROP TRIGGER IF EXISTS on_company_logo_upload on storage.objects;

CREATE TRIGGER on_company_logo_upload BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION tg__set_company_logo_on_upload();


