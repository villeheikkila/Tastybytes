create sequence "public"."profile_push_notification_tokens_id_seq";

create table "public"."profile_push_notification_tokens" (
    "id" bigint not null default nextval('profile_push_notification_tokens_id_seq'::regclass),
    "firebase_registration_token" text not null,
    "created_by" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


alter sequence "public"."profile_push_notification_tokens_id_seq" owned by "public"."profile_push_notification_tokens"."id";

CREATE UNIQUE INDEX profile_push_notification_token_firebase_registration_token_key ON public.profile_push_notification_tokens USING btree (firebase_registration_token);

CREATE UNIQUE INDEX profile_push_notification_tokens_pkey ON public.profile_push_notification_tokens USING btree (id);

alter table "public"."profile_push_notification_tokens" add constraint "profile_push_notification_tokens_pkey" PRIMARY KEY using index "profile_push_notification_tokens_pkey";

alter table "public"."profile_push_notification_tokens" add constraint "profile_push_notification_token_firebase_registration_token_key" UNIQUE using index "profile_push_notification_token_firebase_registration_token_key";

alter table "public"."profile_push_notification_tokens" add constraint "profile_push_notification_tokens_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profile_push_notification_tokens" validate constraint "profile_push_notification_tokens_created_by_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__refresh_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = (case
                      when tg_op = 'update' and old.updated_at >= now() then old.updated_at + interval '1 millisecond'
                      else now() end);
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__remove_unused_tokens()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  delete from profile_push_notification_tokens where updated_at < now() - interval '1 month';
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.tg__stamp_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = (case
                      when tg_op = 'update' and old.updated_at >= now() then old.updated_at + interval '1 millisecond'
                      else now() end);
  return new;
end;
$function$
;

create policy "Enable delete for owner"
on "public"."profile_push_notification_tokens"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Enable insert for authenticated users only"
on "public"."profile_push_notification_tokens"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for owner"
on "public"."profile_push_notification_tokens"
as permissive
for select
to authenticated
using ((created_by = auth.uid()));


create policy "Enable update for owner"
on "public"."profile_push_notification_tokens"
as permissive
for update
to authenticated
using ((created_by = auth.uid()))
with check ((created_by = auth.uid()));


CREATE TRIGGER delete_unused_tokens AFTER INSERT ON public.profile_push_notification_tokens FOR EACH STATEMENT EXECUTE FUNCTION tg__remove_unused_tokens();

CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.profile_push_notification_tokens FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_updated_at BEFORE INSERT OR UPDATE ON public.profile_push_notification_tokens FOR EACH ROW EXECUTE FUNCTION tg__stamp_updated_at();


