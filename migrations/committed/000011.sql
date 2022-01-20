--! Previous: sha1:85bf380f2dce8f10e4e7b719dcd4bb6ec41c4377
--! Hash: sha1:e6b070e64c2075f4df8a9637a2605398b32bb837

-- Enter migration here
alter table tasted_public.brands add created_at timestamp with time zone default now() not null;
alter table tasted_public.brands add updated_at timestamp with time zone default now() not null;
alter table tasted_public.brands add created_by uuid references tasted_public.users(id) on delete set null;
alter table tasted_public.brands add updated_by uuid references tasted_public.users(id) on delete set null;
