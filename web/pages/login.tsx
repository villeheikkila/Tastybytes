import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { useUser } from "@supabase/auth-helpers-react";
import { Auth } from "@supabase/ui";
import { Navbar, Page } from "konsta/react";
import { useRouter } from "next/router";
import { useEffect } from "react";

const LoginPage = () => {
  const { user } = useUser();
  console.log("user: ", user);
  const router = useRouter();

  useEffect(() => {
    if (user?.id) {
      router.push("/");
    }
  }, [user?.id, router]);

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
