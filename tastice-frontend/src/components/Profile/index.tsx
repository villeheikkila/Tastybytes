import * as React from "react";
import { IUserObject } from "../../types";

export const Profile: React.FC<IUserObject> = ({ user }) => {
  if (user === null) {
    return null;
  }

  return (
    <div>
      <p>
        name: {user.name} email: {user.email} id: {user.id}
      </p>
    </div>
  );
};
