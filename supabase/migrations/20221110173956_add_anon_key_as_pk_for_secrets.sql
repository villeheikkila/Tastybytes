alter table "public"."secrets" drop column "firebase_cloud_messaging_access_token";

alter table "public"."secrets" add column "firebase_access_token" text;

alter table "public"."secrets" add column "supabase_anon_key" text not null;

CREATE UNIQUE INDEX secrets_pk ON public.secrets USING btree (supabase_anon_key);

alter table "public"."secrets" add constraint "secrets_pk" PRIMARY KEY using index "secrets_pk";


