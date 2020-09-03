import React from "react";
import { gql, useLazyQuery } from "@apollo/client";
import { useForm } from "react-hook-form";

const Landing = () => {
  const [logIn, { data }] = useLazyQuery<any>(LOGIN);

  console.log("data: ", data);

  const { register, handleSubmit } = useForm();
  const onSubmit = async ({ email }: any) => {
    await logIn({
      variables: {
        email,
      },
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input name="email" ref={register({ required: true })} />
      <input type="submit" />
    </form>
  );
};

const LOGIN = gql`
  mutation LogIn($email: String!) {
    logIn(email: $email)
  }
`;

export default Landing;
