import React from "react";
import { useParams } from "react-router-dom";
import { useMutation } from "@apollo/client";
import { VERIFY_EMAIL } from "./grapqh";

const VerifyAccount = () => {
  const { token } = useParams<{ token: string }>();
  const [verifyAccount] = useMutation(VERIFY_EMAIL);

  const onClick = async () => {
    try {
      const response = await verifyAccount({
        variables: {
          token,
        },
      });
      console.log(response);
    } catch (error) {
      console.error(error);
    }
  };

  onClick();
  return (
    <div>
      <input />
    </div>
  );
};

export default VerifyAccount;
