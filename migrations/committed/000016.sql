--! Previous: sha1:32c6634e51af96e6b34cb296377f59aab44e0279
--! Hash: sha1:7f86b674ea6b4bd9c922cca0a89cb3ac75d528cd

-- Enter migration here
alter table tasted_public.companies drop constraint companies_name_check;
