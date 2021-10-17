--! Previous: sha1:75a22705ed605efe9977682348d29a05a6849aa9
--! Hash: sha1:1b2db9b78acbec09569d11a908e41d2bac3446d7

--! split: 1-current.sql
-- Enter migration here
CREATE TYPE friend_status AS ENUM (
  'friend',
  'pending-sent',
  'pending-received',
  'none'
);
