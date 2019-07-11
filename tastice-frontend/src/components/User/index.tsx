import * as React from "react";
import { IUser } from "../../types";

export const User: React.FC<IUser> = ({ firstName, lastName, email, id }) => {
  return (
    <div>
      <p>
        name: {firstName} {lastName}email: {email} id: {id}{" "}
      </p>
    </div>
  );
};
