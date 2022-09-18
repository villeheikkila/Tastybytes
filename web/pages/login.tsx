import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { Auth } from "@supabase/ui";
import { Navbar, Page } from "konsta/react";
import { useRouter } from "next/router";
import { useEffect } from "react";

const LoginPage = () => {
  const router = useRouter();

  useEffect(() => {
    const { data: listener } = supabaseClient.auth.onAuthStateChange(
      async (_event, session) => {
        if (session) {
          router.push("/");
        }
      }
    );
    return () => {
      listener?.unsubscribe();
    };
  }, []);

  return (
    <Page>
      <Navbar title="Login" />

      <main className="grid h-screen justify-center">
        <div>
          <Auth
            supabaseClient={supabaseClient}
            providers={[]}
            socialLayout="horizontal"
            socialButtonSize="xlarge"
          />
        </div>
      </main>
    </Page>
  );
};

export default LoginPage;
