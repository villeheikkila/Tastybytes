alter table "public"."profiles" add column "joined_at" timestamp with time zone not null default now();
