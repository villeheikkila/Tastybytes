--! Previous: sha1:5fb6ad7ddab02b5b5a3966d8cdd791cfac9704c1
--! Hash: sha1:7aa2722b2b831296f64e77cc5ee08141207c8535

-- Enter migration here
CREATE DOMAIN tasted_public.medium_text AS text
	CONSTRAINT medium_text_check CHECK (((length(VALUE) >= 2) AND (length(VALUE) <= 128)));

alter table tasted_public.companies alter column name type tasted_public.medium_text;
