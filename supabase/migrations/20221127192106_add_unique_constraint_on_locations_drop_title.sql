alter table "public"."locations" drop constraint "locations_name_title_longitude_latitude_country_code_key";

drop index if exists "public"."locations_name_title_longitude_latitude_country_code_key";

CREATE UNIQUE INDEX locations_name_longitude_latitude_country_code_key ON public.locations USING btree (name, longitude, latitude, country_code);

alter table "public"."locations" add constraint "locations_name_longitude_latitude_country_code_key" UNIQUE using index "locations_name_longitude_latitude_country_code_key";
