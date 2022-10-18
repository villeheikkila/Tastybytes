alter table "public"."serving_styles" drop constraint "serving_style_category_id_fkey";

alter table "public"."serving_styles" drop constraint "unique_name_category";

drop index if exists "public"."unique_name_category";

create table "public"."category_serving_styles" (
    "category_id" bigint not null,
    "serving_style_id" bigint not null
);


alter table "public"."serving_styles" drop column "category_id";

CREATE UNIQUE INDEX category_serving_styles_pkey ON public.category_serving_styles USING btree (category_id, serving_style_id);

alter table "public"."category_serving_styles" add constraint "category_serving_styles_pkey" PRIMARY KEY using index "category_serving_styles_pkey";

alter table "public"."category_serving_styles" add constraint "category_serving_styles_category_id_fkey" FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE not valid;

alter table "public"."category_serving_styles" validate constraint "category_serving_styles_category_id_fkey";

alter table "public"."category_serving_styles" add constraint "category_serving_styles_serving_style_id_fkey" FOREIGN KEY (serving_style_id) REFERENCES serving_styles(id) ON DELETE CASCADE not valid;

alter table "public"."category_serving_styles" validate constraint "category_serving_styles_serving_style_id_fkey";


