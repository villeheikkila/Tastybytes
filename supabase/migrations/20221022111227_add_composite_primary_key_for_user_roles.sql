CREATE UNIQUE INDEX users_roles_pkey ON public.users_roles USING btree (user_id, role_id);

alter table "public"."users_roles" add constraint "users_roles_pkey" PRIMARY KEY using index "users_roles_pkey";


