import { Button, Input, SharedLayout } from "@app/components";
import { styled } from "@app/components/src/stitches.config";
import { useSharedQuery, useVerifyEmailMutation } from "@app/graphql";
import { NextPage } from "next";
import React, { useEffect } from "react";

interface VerifyPageProps {
  id: string | null;
  token: string | null;
}

const VerifyPage: NextPage<VerifyPageProps> = (props) => {
  const [error, setError] = React.useState<Error | null>(null);
  const [verifyEmail] = useVerifyEmailMutation();
  const query = useSharedQuery();

  const [[id, token], setIdAndToken] = React.useState<[string, string]>([
    props.id || "",
    props.token || "",
  ]);

  const [state, setState] = React.useState<
    "PENDING" | "SUBMITTING" | "SUCCESS"
  >(props.id && props.token ? "SUBMITTING" : "PENDING");

  useEffect(() => {
    if (state === "SUBMITTING") {
      setError(null);
      verifyEmail({
        variables: {
          id,
          token,
        },
      })
        .then((result) => {
          if (result?.data?.verifyEmail?.success) {
            setState("SUCCESS");
          } else {
            setState("PENDING");
            setError(new Error("Incorrect token, please check and try again"));
          }
        })
        .catch((e: Error) => {
          setError(e);
          setState("PENDING");
        });
    }
  }, [id, token, state, props, verifyEmail]);

  return (
    <SharedLayout title="Verify Email Address" query={query} hideNavigation>
      <Wrapper>
        {state === "PENDING" ? (
          <Form onSubmit={() => setState("SUBMITTING")}>
            <header>
              <h1>Email Verification</h1>
            </header>
            <p>Please enter your email verification code</p>
            <Input
              type="text"
              value={token}
              onChange={(e) => setIdAndToken([id, e.target.value])}
            />
            {error ? <p>{error.message || error}</p> : null}
            <Button>Submit</Button>
          </Form>
        ) : state === "SUBMITTING" ? (
          <header>
            <h1>Submitting...</h1>
          </header>
        ) : state === "SUCCESS" ? (
          <>
            <header>
              <h1>Email Verified!</h1>
            </header>
            <p>
              Thank you for verifying your email address. You may now close this
              window.
            </p>
          </>
        ) : (
          "Unknown state"
        )}
      </Wrapper>
    </SharedLayout>
  );
};

const Wrapper = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});

const Form = styled("form", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
  width: "380px",
});

VerifyPage.getInitialProps = async ({ query: { id, token } }) => ({
  id: typeof id === "string" ? id : null,
  token: typeof token === "string" ? token : null,
});

export default VerifyPage;
