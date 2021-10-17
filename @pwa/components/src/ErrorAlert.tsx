import { ApolloError } from "@apollo/client";
import React from "react";

export interface ErrorAlertProps {
  error: ApolloError | Error;
}

export function ErrorAlert({ error }: ErrorAlertProps) {
  const code: string | undefined = (error as any)?.networkError?.result
    ?.errors?.[0]?.code;
  if (code === "EBADCSRFTOKEN") {
    return (
      <div>
        403 Invalid CSRF token
        <p>
          Our security protections have failed to authenticate your request; to
          solve this you need to refresh the page:
        </p>
        <p>
          <button onClick={() => window.location.reload()}>Refresh page</button>
        </p>
      </div>
    );
  }
  return (
    <div>
      Unexpected error occurred"
      <span>
        We're really sorry, but an unexpected error occurred. Please{" "}
        <a href="/">return to the homepage</a> and try again.
      </span>
      {error.message}
    </div>
  );
}
