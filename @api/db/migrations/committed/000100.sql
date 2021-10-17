--! Previous: sha1:0f393b70925eb52605a3421e2133e57776eacf2e
--! Hash: sha1:bcee1d14b8901905816ceba92ad906f3d6ab4f43

--! split: 1-current.sql
-- Enter migration here
alter table app_public.friend_requests add constraint sender_is_not_receiver check (
    sender_id != receiver_id
);
