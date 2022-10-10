create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.tg__create_profile_for_new_user();