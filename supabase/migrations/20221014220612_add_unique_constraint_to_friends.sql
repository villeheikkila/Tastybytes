CREATE UNIQUE INDEX friends_user_id_1_user_id_2_key ON public.friends USING btree (user_id_1, user_id_2);

alter table "public"."friends" add constraint "friends_user_id_1_user_id_2_key" UNIQUE using index "friends_user_id_1_user_id_2_key";


