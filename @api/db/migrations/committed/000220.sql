--! Previous: sha1:0e184cb9dd694ef69306bb5cfc20b794f41032fd
--! Hash: sha1:a6223bc2555e77f1d9c4570124b19919cb3bb866

--! split: 1-current.sql
-- Enter migration here
alter table app_public.brands drop constraint brands_company_id_fkey;

alter table app_public.brands
	add constraint brands_company_id_fkey
		foreign key (company_id) references app_public.companies
			on delete cascade;
