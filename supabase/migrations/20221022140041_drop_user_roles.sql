alter table "public"."users_roles" drop constraint "user_roles_role_id_fkey";

alter table "public"."users_roles" drop constraint "user_roles_user_id_role_id_key";

alter table "public"."users_roles" drop constraint "users_roles_profiles_id_fk";

alter table "public"."users_roles" drop constraint "users_roles_pkey";

drop index if exists "public"."user_roles_user_id_role_id_key";

drop index if exists "public"."users_roles_pkey";

drop table "public"."users_roles";


