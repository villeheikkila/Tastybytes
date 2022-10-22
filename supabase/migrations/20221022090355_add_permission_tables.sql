create sequence "public"."permissions_id_seq";

alter table "public"."user_roles" drop constraint "user_roles_role_id_fkey";

alter table "public"."user_roles" drop constraint "user_roles_user_id_fkey";

alter table "public"."user_roles" drop constraint "user_roles_user_id_role_id_key";

drop index if exists "public"."user_roles_user_id_role_id_key";

drop table "public"."user_roles";

create table "public"."permissions" (
    "id" bigint not null default nextval('permissions_id_seq'::regclass),
    "name" text not null
);


create table "public"."roles_permissions" (
    "role_id" bigint not null,
    "permission_id" bigint not null
);


create table "public"."users_roles" (
    "user_id" uuid not null,
    "role_id" bigint not null
);


alter table "public"."users_roles" enable row level security;

alter sequence "public"."permissions_id_seq" owned by "public"."permissions"."id";

CREATE UNIQUE INDEX role_permission_pk ON public.permissions USING btree (id);

CREATE UNIQUE INDEX roles_permissions_pkey ON public.roles_permissions USING btree (role_id, permission_id);

CREATE UNIQUE INDEX user_roles_user_id_role_id_key ON public.users_roles USING btree (user_id, role_id);

alter table "public"."permissions" add constraint "role_permission_pk" PRIMARY KEY using index "role_permission_pk";

alter table "public"."roles_permissions" add constraint "roles_permissions_pkey" PRIMARY KEY using index "roles_permissions_pkey";

alter table "public"."roles_permissions" add constraint "roles_permissions_permission_id_fkey" FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE not valid;

alter table "public"."roles_permissions" validate constraint "roles_permissions_permission_id_fkey";

alter table "public"."roles_permissions" add constraint "roles_permissions_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE not valid;

alter table "public"."roles_permissions" validate constraint "roles_permissions_role_id_fkey";

alter table "public"."users_roles" add constraint "user_roles_role_id_fkey" FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE not valid;

alter table "public"."users_roles" validate constraint "user_roles_role_id_fkey";

alter table "public"."users_roles" add constraint "user_roles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."users_roles" validate constraint "user_roles_user_id_fkey";

alter table "public"."users_roles" add constraint "user_roles_user_id_role_id_key" UNIQUE using index "user_roles_user_id_role_id_key";


