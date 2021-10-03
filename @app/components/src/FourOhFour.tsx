import { User } from "@app/graphql";
import React from "react";

import { ButtonLink } from "./ButtonLink";

interface FourOhFourProps {
  currentUser?: Pick<User, "id"> | null;
}

export const FourOhFour = ({ currentUser }: FourOhFourProps) => {
  return (
    <div>
      404
      {`The page you attempted to load was not found.${
        currentUser ? "" : " Maybe you need to log in?"
      }`}
      <ButtonLink href="/">Back Home</ButtonLink>
    </div>
  );
};
