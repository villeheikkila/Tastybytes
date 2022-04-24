import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { redirect } from "@remix-run/node";
import { json } from "@remix-run/node";
import { Form, Link, useActionData, useTransition } from "@remix-run/react";
import { getFormData } from "remix-params-helper";
import { z } from "zod";
import { supabaseStrategy } from "~/auth.server";
import { styled } from "~/stitches.config";
import { supabaseClient } from "~/supabase";
import { paths } from "~/utils";

export const action: ActionFunction = async ({ request }) => {
  const {
    success,
    data: signUpForm,
    errors,
  } = await getFormData(
    request,
    z
      .object({
        email: z.string().email().optional(),
        password: z.string(),
        confirm: z.string(),
      })
      .refine((data) => data.password === data.confirm, {
        message: "Passwords don't match",
        path: ["confirm"],
      })
  );

  if (success) {
    const { session, error } = await supabaseClient.auth.signUp({
      email: signUpForm.email,
      password: signUpForm.password,
    });

    if (!error) {
      return redirect("/");
    }

    return json({ errors: error });
  }

  return json({ errors });
};

export const loader: LoaderFunction = async ({ request }) => {
  await supabaseStrategy.checkSession(request, {
    successRedirect: "/",
  });

  return null;
};

export default function Screen() {
  const data = useActionData();
  const transition = useTransition();

  const isSubmitting = transition.state === "submitting";

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
          Already have an account? <Link to={paths.login}>Login!</Link>
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
          autoComplete="new-password"
          name="password"
          id="password"
        />
        <Input
          type="password"
          placeholder="Confirm password"
          aria-label="password"
          autoComplete="new-password"
          name="confirm"
          id="confirm-password"
        />
        <Button disabled={isSubmitting}>Sign Up</Button>
        {JSON.stringify(data?.errors)}
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
  "&:disabled": {
    backgroundColor: "$darkGray",
  },
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
