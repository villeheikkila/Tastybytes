import React from "react";
import { useParams } from "react-router-dom";
import { gql, useMutation } from "@apollo/client";

const VerifyAccount = () => {
  const { token } = useParams();
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
  return <div></div>;
};

const VERIFY_EMAIL = gql`
  mutation VerifyAccount($token: String!) {
    verifyAccount(token: $token)
  }
`;

export default VerifyAccount;
