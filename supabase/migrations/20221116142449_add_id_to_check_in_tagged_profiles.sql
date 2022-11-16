create sequence "public"."check_in_tagged_profiles_id_seq";

alter table "public"."check_in_tagged_profiles" add column "id" bigint not null default nextval('check_in_tagged_profiles_id_seq'::regclass);

alter sequence "public"."check_in_tagged_profiles_id_seq" owned by "public"."check_in_tagged_profiles"."id";

CREATE UNIQUE INDEX check_in_tagged_profiles_pkey ON public.check_in_tagged_profiles USING btree (id);

alter table "public"."check_in_tagged_profiles" add constraint "check_in_tagged_profiles_pkey" PRIMARY KEY using index "check_in_tagged_profiles_pkey";


