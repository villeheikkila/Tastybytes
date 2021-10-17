--! Previous: sha1:88727b453745568033c71db3417a8c41367b517b
--! Hash: sha1:294bb99163473836204da0877ac5ed7f56d8c7b8

--! split: 1-current.sql
-- Enter migration here
drop POLICY select_public ON app_public.check_ins;
