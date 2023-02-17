drop view if exists "public"."product_user_ratings";

alter table "public"."check_ins" rename column "image_url" to "image_file";