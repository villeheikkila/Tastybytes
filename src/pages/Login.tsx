import { Button, Container, Input, Row } from "@nextui-org/react";
import { useState } from "react";
import { Navigate, useNavigate } from "react-router-dom";
import { useSignIn } from "../hooks/useAuth";
import { Table } from "@nextui-org/react";
import TastedTable from "../components/tasting-table";

export default function Login() {
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  const [{ error, fetching, session, user }, signIn] = useSignIn();
  const handleLogin = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    try {
      setLoading(true);
      await signIn({ email, password }).then(() => navigate("/"));
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  if (error) return <div>Error signing in</div>;
  if (fetching) return <div>Signing in</div>;
  if (user) return <div>Logged in</div>;

  return (
    <div>
      <Container fluid>
        <h1>Tasted</h1>
        <p>Sign in via magic link with your email below</p>
        {loading ? (
          "Sending magic link..."
        ) : (
          <form onSubmit={handleLogin}>
            <Row align="center">
              <Input
                id="email"
                type="email"
                aria-label="email"
                placeholder="Your email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </Row>

            <Row align="center">
              <Input.Password
                aria-label="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </Row>

            <Button aria-live="polite" type="submit">
              Send magic link
            </Button>
          </form>
        )}
      </Container>
    </div>
  );
}
