import { Button, Container, Input, Row, styled, Text } from "@nextui-org/react";
import { SupabaseClient } from "@supabase/supabase-js";
import React, { useState } from "react";

export type AuthViews =
  | "forgotten_password"
  | "sign_in"
  | "magic_link"
  | "sign_up"
  | "update_password";

interface AuthProps {
  supabaseClient: SupabaseClient;
  authView: AuthViews;
  setAuthView: (v: AuthViews) => void;
}
function Auth({ supabaseClient, authView, setAuthView }: AuthProps) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSignIn = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    const { error: signInError } = await supabaseClient.auth.signIn({
      email,
      password,
    });
    if (signInError) setError(signInError.message);

    setLoading(false);
  };

  const handleSignUp = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    const { error: signUpError } = await supabaseClient.auth.signUp({
      email,
      password,
    });
    if (signUpError) setError(signUpError.message);

    setLoading(false);
  };

  const handlePasswordReset = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setMessage("");
    setLoading(true);
    const { error } = await supabaseClient.auth.api.resetPasswordForEmail(
      email
    );
    if (error) setError(error.message);
    else setMessage("Check your email for the password reset link");
    setLoading(false);
  };

  const handleMagicLinkSignIn = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setMessage("");
    setLoading(true);
    const { error } = await supabaseClient.auth.signIn({ email });
    if (error) setError(error.message);
    else setMessage("Check your email for the magic link");
    setLoading(false);
  };

  return (
    <>
      {loading && <h3>Loading..</h3>}
      {error && <div style={{ color: "red" }}>{error}</div>}
      {message && <div style={{ color: "green" }}>{message}</div>}
      {authView === "sign_in" ? (
        <>
          <Form onSubmit={(e) => handleSignIn(e)}>
            <Row justify="center" align="center" gap={1}>
              <Text>Don't have an account?</Text>
              <a onClick={() => setAuthView("sign_up")}>Sign up</a>
            </Row>
            <Input
              id="sign-in__email"
              autoComplete="email"
              placeholder="Type in your email address"
              defaultValue={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <Input
              id="sign-in__password"
              type="password"
              placeholder="Password"
              defaultValue={password}
              autoComplete="current-password"
              onChange={(e) => setPassword(e.target.value)}
            />
            <a onClick={() => setAuthView("forgotten_password")}>
              Forgot my password
            </a>
            <Button type="submit">Sign In</Button>
          </Form>
          <hr />
          <Row css={{ width: "100%" }}>
            <Button onClick={() => setAuthView("magic_link")}>
              Send magic link email
            </Button>
          </Row>
        </>
      ) : authView === "sign_up" ? (
        <>
          <h4>Sign up</h4>
          <Form onSubmit={(e) => handleSignUp(e)}>
            <label htmlFor="sign-up__email">Email</label>
            <Input
              id="sign-up__email"
              autoComplete="email"
              placeholder="Type in your email address"
              defaultValue={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <label htmlFor="sign-up__password">Password</label>
            <Input
              id="sign-up__password"
              type="password"
              defaultValue={password}
              autoComplete="current-password"
              onChange={(e) => setPassword(e.target.value)}
            />
            <Button type="submit">SignUp</Button>
          </Form>
          <hr />
          <a onClick={() => setAuthView("sign_in")}>
            Already have an account, Sign in
          </a>
          <a onClick={() => setAuthView("forgotten_password")}>
            Forgot my password
          </a>
          <hr />
          <a onClick={() => setAuthView("magic_link")}>Send magic link email</a>
        </>
      ) : authView === "forgotten_password" ? (
        <>
          <h4>Forgotten password</h4>
          <Form onSubmit={handlePasswordReset}>
            <label htmlFor="forgotten_password__email">Email</label>
            <Input
              id="forgotten_password__email"
              autoComplete="email"
              placeholder="Type in your email address"
              defaultValue={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <Button type="submit">Send reset password instructions</Button>
          </Form>
          <hr />
          <a onClick={() => setAuthView("sign_up")}>
            Don't have an account? Sign up
          </a>
          <a onClick={() => setAuthView("sign_in")}>
            Already have an account, Sign in
          </a>
          <hr />
          <a onClick={() => setAuthView("magic_link")}>Send magic link email</a>
        </>
      ) : authView === "magic_link" ? (
        <>
          <h4>Magic link</h4>
          <Form onSubmit={handleMagicLinkSignIn}>
            <Input
              autoComplete="email"
              placeholder="Type in your email address"
              defaultValue={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <Button type="submit">Send magic link</Button>
          </Form>
          <hr />
          <a onClick={() => setAuthView("sign_up")}>
            Don't have an account? Sign up
          </a>
          <a onClick={() => setAuthView("sign_in")}>
            Already have an account, Sign in
          </a>
        </>
      ) : null}
    </>
  );
}

function UpdatePassword({
  supabaseClient,
}: {
  supabaseClient: SupabaseClient;
}) {
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);

  const handlePasswordReset = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setError("");
    setMessage("");
    setLoading(true);
    const { error } = await supabaseClient.auth.update({ password });
    if (error) setError(error.message);
    else setMessage("Your password has been updated");
    setLoading(false);
  };

  return (
    <>
      {loading && <h3>Loading..</h3>}
      {error && <div style={{ color: "red" }}>{error}</div>}
      {message && <div style={{ color: "green" }}>{message}</div>}
      <Text h4>Set a new password</Text>
      <Form onSubmit={handlePasswordReset}>
        <Input
          placeholder="Enter your new password"
          type="password"
          onChange={(e) => setPassword(e.target.value)}
        />
        <Button type="submit">Update password</Button>
      </Form>
    </>
  );
}

const Form = styled("form", {
  display: "flex",
  flexDirection: "column",
  gap: "0.5rem",
  width: "340px",
} as any);

Auth.UpdatePassword = UpdatePassword;
export default Auth;
