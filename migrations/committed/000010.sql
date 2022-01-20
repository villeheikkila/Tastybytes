--! Previous: sha1:b87e3470dfa465f56370c3c0a9518be570ab7b3b
--! Hash: sha1:85bf380f2dce8f10e4e7b719dcd4bb6ec41c4377

-- Enter migration here
CREATE FUNCTION tasted_private.tg__timestamps() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public', 'pg_temp'
    AS $$
begin
  NEW.created_at = (case when TG_OP = 'INSERT' then NOW() else OLD.created_at end);
  NEW.updated_at = (case when TG_OP = 'UPDATE' and OLD.updated_at >= NOW() then OLD.updated_at + interval '1 millisecond' else NOW() end);
  return NEW;
end;
$$;

CREATE TRIGGER _100_timestamps BEFORE INSERT OR UPDATE ON tasted_public.products FOR EACH ROW EXECUTE FUNCTION tasted_private.tg__timestamps();
