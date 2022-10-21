create sequence "public"."notifications_id_seq";

create table "public"."notifications" (
    "id" bigint not null default nextval('notifications_id_seq'::regclass),
    "message" text,
    "profile_id" uuid,
    "created_at" timestamp with time zone default now()
);


alter table "public"."notifications" enable row level security;

alter table "public"."category_serving_styles" enable row level security;

alter table "public"."product_variants" enable row level security;

alter table "public"."sub_brands" enable row level security;

alter sequence "public"."notifications_id_seq" owned by "public"."notifications"."id";

CREATE UNIQUE INDEX notifications_pk ON public.notifications USING btree (id);

alter table "public"."notifications" add constraint "notifications_pk" PRIMARY KEY using index "notifications_pk";

alter table "public"."notifications" add constraint "notifications_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."notifications" validate constraint "notifications_profile_id_fkey";

create policy "Enable read access for all users"
on "public"."category_serving_styles"
as permissive
for select
to public
using (true);


create policy "Enable read access for intended user"
on "public"."notifications"
as permissive
for select
to authenticated
using ((profile_id = auth.uid()));


create policy "Enable read access for all users"
on "public"."product_variants"
as permissive
for select
to public
using (true);


create policy "Enable read access for all users"
on "public"."roles"
as permissive
for select
to public
using (true);



