--! Previous: sha1:7aa2722b2b831296f64e77cc5ee08141207c8535
--! Hash: sha1:32c6634e51af96e6b34cb296377f59aab44e0279

-- Enter migration here
alter table tasted_public.companies drop constraint companies_name_key;
