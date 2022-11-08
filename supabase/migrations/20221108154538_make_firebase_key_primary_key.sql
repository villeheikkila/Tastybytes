ALTER TABLE "public"."profile_push_notification_tokens"
  DROP CONSTRAINT "profile_push_notification_tokens_pkey";

DROP INDEX IF EXISTS "public"."profile_push_notification_tokens_pkey";

ALTER TABLE "public"."profile_push_notification_tokens"
  DROP COLUMN "id";

DROP SEQUENCE IF EXISTS "public"."profile_push_notification_tokens_id_seq";

CREATE UNIQUE INDEX profile_push_notification_tokens_pkey ON public.profile_push_notification_tokens USING btree (firebase_registration_token);

ALTER TABLE "public"."profile_push_notification_tokens"
  ADD CONSTRAINT "profile_push_notification_tokens_pkey" PRIMARY KEY USING INDEX "profile_push_notification_tokens_pkey";

