import { Session, SupabaseClient, User } from "@supabase/supabase-js";
import React, { useEffect, useState, createContext, useContext } from "react";

const UserContext = createContext<{
  user: null | User;
  session: null | Session;
}>({ user: null, session: null });

type WithChildren<T = {}> = T & { children?: React.ReactNode };

interface UserContextProviderProps {
  supabaseClient: SupabaseClient;
}
export const UserContextProvider = ({
  supabaseClient,
  children,
}: WithChildren<UserContextProviderProps>) => {
  const [session, setSession] = useState<Session | null>(null);
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    const session = supabaseClient.auth.session();
    setSession(session);
    setUser(session?.user ?? null);
    const { data: authListener } = supabaseClient.auth.onAuthStateChange(
      async (event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
      }
    );

    return () => {
      authListener?.unsubscribe();
    };
  }, []);

  const value = {
    session,
    user,
  };

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
};

export const useUser = () => {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error(`useUser must be used within a UserContextProvider.`);
  }
  return context;
};
