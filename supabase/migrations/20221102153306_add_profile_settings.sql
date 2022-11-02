create table "public"."profile_settings" (
    "id" uuid not null,
    "color_scheme" enum__color_scheme not null default 'system'::enum__color_scheme,
    "send_reaction_notifications" boolean not null default true,
    "send_tagged_check_in_notifications" boolean not null default true,
    "send_friend_request_notifications" boolean not null default true
);


alter table "public"."profiles" drop column "color_scheme";

CREATE UNIQUE INDEX profile_settings_pkey ON public.profile_settings USING btree (id);

alter table "public"."profile_settings" add constraint "profile_settings_pkey" PRIMARY KEY using index "profile_settings_pkey";

alter table "public"."profile_settings" add constraint "profile_settings_id_fkey" FOREIGN KEY (id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."profile_settings" validate constraint "profile_settings_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.tg__create_profile_settings()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
    insert
    into public.profile_settings (id)
    values (new.id);
    return new;
end;
$function$
;

CREATE TRIGGER add_options_for_profile AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION tg__create_profile_settings();


