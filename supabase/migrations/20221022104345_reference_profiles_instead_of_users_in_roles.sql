alter table "public"."users_roles" drop constraint "user_roles_user_id_fkey";

alter table "public"."users_roles" add constraint "users_roles_profiles_id_fk" FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."users_roles" validate constraint "users_roles_profiles_id_fk";


