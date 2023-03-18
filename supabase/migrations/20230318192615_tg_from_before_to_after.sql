drop trigger on_product_logo_upload on storage.objects;

create trigger on_product_logo_upload
  after insert
  on storage.objects
  for each row
execute procedure public.tg__set_product_logo_on_upload();

