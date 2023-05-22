drop trigger if exists "delete_unused_tokens" on "public"."profile_push_notification_tokens";

drop trigger if exists "stamp_created_by" on "public"."profile_push_notification_tokens";

drop trigger if exists "stamp_updated_at" on "public"."profile_push_notification_tokens";

drop policy "Enable delete for owner" on "public"."profile_push_notification_tokens";

drop policy "Enable insert for authenticated users only" on "public"."profile_push_notification_tokens";

drop policy "Enable read access for owner" on "public"."profile_push_notification_tokens";

drop policy "Enable update for owner" on "public"."profile_push_notification_tokens";

alter table "public"."profile_push_notification_tokens" drop constraint "profile_push_notification_token_firebase_registration_token_key";

alter table "public"."profile_push_notification_tokens" drop constraint "profile_push_notification_tokens_created_by_fkey";

alter table "public"."profile_push_notification_tokens" drop constraint "profile_push_notification_tokens_pkey";

drop index if exists "public"."profile_push_notification_token_firebase_registration_token_key";

drop index if exists "public"."profile_push_notification_tokens_pkey";

drop table "public"."profile_push_notification_tokens";

create table "public"."profile_push_notifications" (
    "firebase_registration_token" text not null,
    "created_by" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
);


alter table "public"."profile_push_notifications" enable row level security;

CREATE UNIQUE INDEX profile_push_notification_token_firebase_registration_token_key ON public.profile_push_notifications USING btree (firebase_registration_token);

CREATE UNIQUE INDEX profile_push_notification_tokens_pkey ON public.profile_push_notifications USING btree (firebase_registration_token);

alter table "public"."profile_push_notifications" add constraint "profile_push_notification_tokens_pkey" PRIMARY KEY using index "profile_push_notification_tokens_pkey";

alter table "public"."profile_push_notifications" add constraint "profile_push_notification_token_firebase_registration_token_key" UNIQUE using index "profile_push_notification_token_firebase_registration_token_key";

alter table "public"."profile_push_notifications" add constraint "profile_push_notification_tokens_created_by_fkey" FOREIGN KEY (created_by) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profile_push_notifications" validate constraint "profile_push_notification_tokens_created_by_fkey";

create policy "Enable delete for owner"
on "public"."profile_push_notifications"
as permissive
for delete
to authenticated
using ((auth.uid() = created_by));


create policy "Enable insert for authenticated users only"
on "public"."profile_push_notifications"
as permissive
for insert
to authenticated
with check (true);


create policy "Enable read access for owner"
on "public"."profile_push_notifications"
as permissive
for select
to authenticated
using ((created_by = auth.uid()));


create policy "Enable update for owner"
on "public"."profile_push_notifications"
as permissive
for update
to authenticated
using ((created_by = auth.uid()))
with check ((created_by = auth.uid()));


CREATE TRIGGER delete_unused_tokens AFTER INSERT ON public.profile_push_notifications FOR EACH STATEMENT EXECUTE FUNCTION tg__remove_unused_tokens();

CREATE TRIGGER stamp_created_by BEFORE INSERT OR UPDATE ON public.profile_push_notifications FOR EACH ROW EXECUTE FUNCTION tg__stamp_created_by();

CREATE TRIGGER stamp_updated_at BEFORE INSERT OR UPDATE ON public.profile_push_notifications FOR EACH ROW EXECUTE FUNCTION tg__stamp_updated_at();


