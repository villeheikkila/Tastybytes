--! Previous: sha1:0def60c469c3454c91d5946674fd29f947f8b84d
--! Hash: sha1:380d0bd99b9089ab0336d8892b2d1cf4e84434e7

--! split: 1-current.sql
-- enter migration here

create policy delete_own on app_public.friends for delete using (exists(select 1 from app_public.friends where user_id_1 = app_public.current_user_id() or user_id_2 = app_public.current_user_id()));
