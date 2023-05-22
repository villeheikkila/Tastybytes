alter table "public"."profile_push_notifications" add column "send_friend_request_notifications" boolean not null default false;

alter table "public"."profile_push_notifications" add column "send_reaction_notifications" boolean not null default false;

alter table "public"."profile_push_notifications" add column "send_tagged_check_in_notifications" boolean not null default false;


