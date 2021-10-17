--! Previous: sha1:accbf13e27efc8961b5daf1dba7875e59ed8179e
--! Hash: sha1:eba29fcd0d20c16c32f13fb0fe57b0866af44f6c

--! split: 1-current.sql
-- Enter migration here
CREATE INDEX ON "app_public"."check_in_comments"("created_by")
