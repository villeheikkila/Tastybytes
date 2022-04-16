import { Button, Container, Row, Text } from "@nextui-org/react";
import Link from "next/link";
import { useEffect, useState } from "react";
import useSWR from "swr";
import Auth, { AuthViews } from "../components/Auth";
import { useUser } from "../lib/UserContext";
import { supabase } from "../utils/initSupabase";

const fetcher = (url: string, token: string) =>
  fetch(url, {
    method: "GET",
    headers: new Headers({ "Content-Type": "application/json", token }),
    credentials: "same-origin",
  }).then((res) => res.json());

const Index = () => {
  const { user, session } = useUser();
  const { data, error } = useSWR(
    session ? ["/api/getUser", session?.access_token] : null,
    fetcher
  );
  const [authView, setAuthView] = useState<AuthViews>("sign_in");

  useEffect(() => {
    const { data: authListener } = supabase.auth.onAuthStateChange(
      (event, session) => {
        if (event === "PASSWORD_RECOVERY") setAuthView("update_password");
        if (event === "USER_UPDATED")
          setTimeout(() => setAuthView("sign_in"), 1000);

        fetch("/api/auth", {
          method: "POST",
          headers: new Headers({ "Content-Type": "application/json" }),
          credentials: "same-origin",
          body: JSON.stringify({ event, session }),
        }).then((res) => res.json());
      }
    );

    return () => {
      authListener?.unsubscribe();
    };
  }, []);

  const View = () => {
    if (!user)
      return (
        <Container>
          <Row justify="center" align="center">
            <Text h3>Welcome to Tasted</Text>
          </Row>
          <Auth
            supabaseClient={supabase}
            authView={authView}
            setAuthView={setAuthView}
          />
        </Container>
      );

    return (
      <>
        {authView === "update_password" && (
          <Auth.UpdatePassword supabaseClient={supabase} />
        )}
        {user && (
          <>
            <h4>You're signed in</h4>
            <h5>Email: {user.email}</h5>

            <Button onClick={() => supabase.auth.signOut()}>Log out</Button>
            <hr />
            {error && <div style={{ color: "red" }}>Failed to fetch user!</div>}
            {data && !error ? (
              <>
                <div style={{ color: "green" }}>
                  User data retrieved server-side (in API route):
                </div>

                <pre>{JSON.stringify(data, null, 2)}</pre>
              </>
            ) : (
              <div>Loading...</div>
            )}

            <Link href="/profile">
              <a>SSR example with getServerSideProps</a>
            </Link>
          </>
        )}
      </>
    );
  };

  return (
    <div style={{ maxWidth: "400px", margin: "96px auto" }}>
      <View />
    </div>
  );
};

export default Index;
