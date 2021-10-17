import React from "react";

import { ButtonLink } from "./ButtonLink";

export interface SocialLoginOptionsProps {
  next: string;
  buttonTextFromService?: (service: string) => string;
}

function defaultButtonTextFromService(service: string) {
  return `Sign in with ${service}`;
}

export function SocialLoginOptions({
  next,
  buttonTextFromService = defaultButtonTextFromService,
}: SocialLoginOptionsProps) {
  return (
    <ButtonLink href={`/auth/github?next=${encodeURIComponent(next)}`}>
      {buttonTextFromService("GitHub")}
    </ButtonLink>
  );
}
