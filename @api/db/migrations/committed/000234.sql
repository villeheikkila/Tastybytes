--! Previous: sha1:13ad3705363c1c6a60adf0a2316051247bd2af9b
--! Hash: sha1:3ab5292aaa1d19b062acd6a4e1aab0feab4d0136

--! split: 1-current.sql
-- Enter migration here
alter type app_public.friend_status add value 'blocked';
