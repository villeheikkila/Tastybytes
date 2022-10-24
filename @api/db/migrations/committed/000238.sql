--! Previous: sha1:8e8e63c8c826619fad7a53e1c9269506579e0cc9
--! Hash: sha1:6c21cae0a30dca603ae6a95585b5127ec742810e

--! split: 1-current.sql
-- Enter migration here
create unique index unique_friend_relation_idx
on app_public.friends(
  least(user_id_1, user_id_2)
, greatest(user_id_1, user_id_2)
);
