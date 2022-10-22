create table "public"."profiles_roles" (
    "profile_id" uuid not null,
    "role_id" bigint not null
);


CREATE UNIQUE INDEX profiles_roles_pkey ON public.profiles_roles USING btree (profile_id, role_id);

alter table "public"."profiles_roles" add constraint "profiles_roles_pkey" PRIMARY KEY using index "profiles_roles_pkey";

alter table "public"."profiles_roles" add constraint "profiles_roles_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profiles_roles" validate constraint "profiles_roles_profile_id_fkey";

alter table "public"."profiles_roles" add constraint "profiles_roles_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE not valid;

alter table "public"."profiles_roles" validate constraint "profiles_roles_role_id_fkey";


