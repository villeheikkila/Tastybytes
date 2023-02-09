alter table "public"."profiles" add column "is_onboarded" boolean not null default false;

alter table "public"."profiles" alter column "is_private" set not null;


