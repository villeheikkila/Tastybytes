--! Previous: sha1:1b2db9b78acbec09569d11a908e41d2bac3446d7
--! Hash: sha1:778dedc742cfab2b152900717ed43ec8145fb64c

--! split: 1-current.sql
-- Enter migration here
DROP TYPE friend_status;

CREATE TYPE app_public.friend_status AS ENUM (
  'friend',
  'pending-sent',
  'pending-received',
  'none'
);
