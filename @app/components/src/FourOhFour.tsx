import { User } from "@app/graphql";
import React from "react";

import { ButtonLink } from "./ButtonLink";

interface FourOhFourProps {
  currentUser?: Pick<User, "id"> | null;
}

export function FourOhFour(props: FourOhFourProps) {
  const { currentUser } = props;
  console.log("currentUser: ", currentUser);
  return (
    <div>
      404
      {`The page you attempted to load was not found.${
        currentUser ? "" : " Maybe you need to log in?"
      }`}
      <ButtonLink href="/">Back Home</ButtonLink>
    </div>
  );
}
