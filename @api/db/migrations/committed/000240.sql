--! Previous: sha1:71584d393550a74b0c8e80d76a7e3c40d4f6b68d
--! Hash: sha1:578e1f2fbcbd91a5f64dcd72c1c75183f4daf95b

--! split: 1-current.sql
-- Enter migration here
alter table app_public.friends drop constraint friends_user_id_2_fkey;

alter table app_public.friends
	add constraint friends_user_id_2_fkey
		foreign key (user_id_2) references app_public.users
			on delete cascade;

alter table app_public.friends drop constraint friends_user_id_1_fkey;

alter table app_public.friends
	add constraint friends_user_id_1_fkey
		foreign key (user_id_1) references app_public.users
			on delete cascade;
