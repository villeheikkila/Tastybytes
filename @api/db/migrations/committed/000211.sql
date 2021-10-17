--! Previous: sha1:c5d7ec5df0badc5b9513ccdb9108c5f8826128c4
--! Hash: sha1:d00d7e58fa950790467ac0d1319b5907459527be

--! split: 1-current.sql
create policy select_all on app_public.item_edit_suggestions for select using (app_public.current_user_is_privileged());
