alter table "public"."locations" drop constraint "locations_country_city_name_key";

drop index if exists "public"."locations_country_city_name_key";

create table "public"."countries" (
    "country_code" character(2) not null,
    "name" text not null,
    "emoji" text not null
);


alter table "public"."locations" drop column "city";

alter table "public"."locations" drop column "country";

alter table "public"."locations" add column "country_code" character(2) not null;

alter table "public"."locations" add column "created_at" timestamp with time zone not null default now();

alter table "public"."locations" add column "created_by" uuid;

alter table "public"."locations" add column "latitude" numeric;

alter table "public"."locations" add column "longitude" numeric;

alter table "public"."locations" add column "title" text;

alter table "public"."locations" alter column "name" set not null;

CREATE UNIQUE INDEX countries_pkey ON public.countries USING btree (country_code);

alter table "public"."countries" add constraint "countries_pkey" PRIMARY KEY using index "countries_pkey";

alter table "public"."locations" add constraint "locations_countries_fk" FOREIGN KEY (country_code) REFERENCES countries(country_code) ON DELETE CASCADE not valid;

alter table "public"."locations" validate constraint "locations_countries_fk";

alter table "public"."locations" add constraint "locations_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE SET NULL not valid;

alter table "public"."locations" validate constraint "locations_created_by_fkey";

CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.locations FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_at();


