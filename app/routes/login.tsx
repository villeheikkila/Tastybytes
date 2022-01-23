import {
  ActionFunction,
  Form,
  HeadersFunction,
  MetaFunction,
  useActionData,
} from "remix";
import Input from "~/components/input";
import Link from "~/components/link";
import { Typography } from "~/components/typography";
import { styled } from "~/stitches.config";
import { createUserSession, login } from "~/utils/session.server";

export const meta: MetaFunction = () => {
  return {
    title: "Tasted | Login",
    description: "Login to store your tasting notes!",
  };
};

export const headers: HeadersFunction = () => {
  return {
    "Cache-Control": `public, max-age=${60 * 10}, s-maxage=${
      60 * 60 * 24 * 30
    }`,
  };
};

function validateUsername(username: unknown) {
  if (typeof username !== "string" || username.length < 3) {
    return `Usernames must be at least 3 characters long`;
  }
}

function validatePassword(password: unknown) {
  if (typeof password !== "string" || password.length < 6) {
    return `Passwords must be at least 6 characters long`;
  }
}

type ActionData = {
  formError?: string;
  fieldErrors?: { username: string | undefined; password: string | undefined };
  fields?: { username: string; password: string };
};

export const action: ActionFunction = async ({
  request,
}): Promise<Response | ActionData> => {
  const { loginType, username, password } = Object.fromEntries(
    await request.formData()
  );
  if (typeof username !== "string" || typeof password !== "string") {
    return { formError: `Form not submitted correctly.` };
  }

  const fields = { loginType, username, password };
  const fieldErrors = {
    username: validateUsername(username),
    password: validatePassword(password),
  };
  if (Object.values(fieldErrors).some(Boolean)) return { fieldErrors, fields };

  const user = await login({ username, password });
  console.log("user: ", user);

  if (!user) {
    return {
      fields,
      formError: `Username/Password combination is incorrect`,
    };
  }
  return createUserSession(user.id, "/");
};

export default function Login() {
  const actionData = useActionData<ActionData>();

  return (
    <Wrapper data-light="">
      <Header>
        <img color="white" src="/maku.svg" height={48} width={48} />
        <Typography.H1>Welcome to Tasted</Typography.H1>
        <p>
          Don't have an account? <Link to="/register">Sign up!</Link>
        </p>
      </Header>
      <StyledForm
        method="post"
        aria-describedby={
          actionData?.formError ? "form-error-message" : undefined
        }
      >
        <Input
          type="text"
          id="username-input"
          name="username"
          placeholder="Username"
          defaultValue={actionData?.fields?.username}
          aria-invalid={Boolean(actionData?.fieldErrors?.username)}
          aria-describedby={
            actionData?.fieldErrors?.username ? "username-error" : undefined
          }
        />
        {actionData?.fieldErrors?.username ? (
          <ErrorText role="alert" id="username-error">
            {actionData?.fieldErrors.username}
          </ErrorText>
        ) : null}
        <Input
          id="password-input"
          name="password"
          placeholder="Password"
          defaultValue={actionData?.fields?.password}
          type="password"
          aria-invalid={Boolean(actionData?.fieldErrors?.password) || undefined}
          aria-describedby={
            actionData?.fieldErrors?.password ? "password-error" : undefined
          }
        />
        {actionData?.fieldErrors?.password ? (
          <ErrorText role="alert" id="password-error">
            {actionData?.fieldErrors.password}
          </ErrorText>
        ) : null}
        <div id="form-error-message">
          {actionData?.formError ? (
            <ErrorText role="alert">{actionData?.formError}</ErrorText>
          ) : null}
        </div>
        <Button type="submit">Submit</Button>
      </StyledForm>
    </Wrapper>
  );
}

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
