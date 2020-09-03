import React from "react";
import { gql, useMutation } from "@apollo/client";
import { useForm } from "react-hook-form";

const SignUp = () => {
  const [signUpMutation] = useMutation(CREATE_ACCOUNT);
  const { register, handleSubmit } = useForm();
  const onSubmit = async (data: any) => {
    await signUpMutation({
      variables: {
        ...data,
      },
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input name="firstName" ref={register({ required: true })} />
      <input name="lastName" ref={register({ required: true })} />
      <input name="email" ref={register({ required: true })} />
      <input type="submit" />
    </form>
  );
};

const CREATE_ACCOUNT = gql`
  mutation CreateAccount(
    $firstName: String!
    $lastName: String!
    $email: String!
  ) {
    createAccount(firstName: $firstName, lastName: $lastName, email: $email) {
      id
    }
  }
`;

export default SignUp;
