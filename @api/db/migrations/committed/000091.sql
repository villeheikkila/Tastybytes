--! Previous: sha1:7d4c997cd7ff9fb9525ca36b7890c4ceb25f7ac6
--! Hash: sha1:71bb2db3e5dd49dac24ab4f4621868e16b292437

--! split: 1-current.sql
-- Enter migration here

create table app_public.friend_requests (
    sender_id uuid not null references app_public.users(id) on delete cascade,
    receiver_id uuid not null references app_public.users(id) on delete cascade,
    primary key (sender_id, receiver_id),
    unique (receiver_id, sender_id)
);

create table app_public.friends (
    user_id_1 uuid not null references app_public.users(id) on delete cascade,
    user_id_2 uuid not null references app_public.users(id) on delete cascade,
    primary key (user_id_1, user_id_2)
);
