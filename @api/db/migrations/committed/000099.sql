--! Previous: sha1:fbe42d8775dc7669ce7992e3195ded3ddd71c9ec
--! Hash: sha1:0f393b70925eb52605a3421e2133e57776eacf2e

--! split: 1-current.sql
-- Enter migration here
alter table app_public.friend_requests add constraint unique_sender_receiver_id unique (
    sender_id, receiver_id
);
