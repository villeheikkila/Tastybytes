import type { ActionFunction, LoaderFunction } from "remix";
import { json } from "@remix-run/node";
import { Form, Link, useLoaderData } from "@remix-run/react";
import { authenticator, sessionStorage, supabaseStrategy } from "~/auth.server";
import { styled } from "~/stitches.config";

type LoaderData = {
  error: { message: string } | null;
};

export const action: ActionFunction = async ({ request }) => {
  await authenticator.authenticate("sb", request, {
    successRedirect: "/private",
    failureRedirect: "/login",
  });
};

export const loader: LoaderFunction = async ({ request }) => {
  await supabaseStrategy.checkSession(request, {
    successRedirect: "/private",
  });

  const session = await sessionStorage.getSession(
    request.headers.get("Cookie")
  );

  const error = session.get(
    authenticator.sessionErrorKey
  ) as LoaderData["error"];

  return json<LoaderData>({ error });
};

export default function Screen() {
  const { error } = useLoaderData<LoaderData>();

  return (
    <Wrapper data-light="">
      <Header>
        <img
          color="white"
          alt="icon of tasted"
          src="/favicon.svg"
          height={48}
          width={48}
        />
        <H1>Welcome to Tasted</H1>
        <p>
          Don't have an account? <Link to="/register">Sign up!</Link>
        </p>
      </Header>
      <StyledForm method="post">
        <Input
          autoComplete="email"
          aria-label="email"
          type="email"
          name="email"
          id="email"
          placeholder="Email"
        />

        <Input
          type="password"
          placeholder="Password"
          aria-label="password"
          autoComplete="current-password"
          name="password"
          id="password"
        />
        {error && <ErrorText role="alert">{error.message}</ErrorText>}
        <Button>Log In</Button>
      </StyledForm>
    </Wrapper>
  );
}

const H1 = styled("h1", { fontSize: "28px" });

export const ErrorText = styled("em", { color: "$red" });

export const Button = styled("button", {
  backgroundColor: "#0099ff",
  borderRadius: "10px",
  boxShadow: "#000000 0px 1px 2px 0px",
  color: "#ffffff",
  fontSize: "16px",
  fontWeight: 500,
  lineHeight: "15px",
  padding: "0px 16px",
  textAlign: "center",
  height: "40px",
  border: "none",
  variants: {
    variant: {
      warning: {
        backgroundColor: "$red",
      },
    },
  },
});

const Wrapper = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "16px",
  width: "330px",
});

export const Input = styled("input", {
  backgroundColor: "#333333",
  borderRadius: "10px",
  color: "#bababa",
  display: "inline-block",
  padding: "0px 16px",
  fontSize: "16px",
  height: "40px",
  border: "none",
  "&:focus": { outline: "1px solid $blue" },
  transition: "outline 0.4s ease 0s, color 0.2s ease 0s",
  "&[aria-invalid='true']": {
    outline: "1px solid red",
  },
});

const Header = styled("header", {
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  gap: "10px",
});

const StyledForm = styled(Form, {
  display: "flex",
  flexDirection: "column",
  gap: "10px",
});
