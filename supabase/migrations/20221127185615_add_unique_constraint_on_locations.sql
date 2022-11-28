CREATE UNIQUE INDEX locations_name_title_longitude_latitude_country_code_key ON public.locations USING btree (name, title, longitude, latitude, country_code);

alter table "public"."locations" add constraint "locations_name_title_longitude_latitude_country_code_key" UNIQUE using index "locations_name_title_longitude_latitude_country_code_key";


