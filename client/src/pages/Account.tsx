import React from "react";
import { useQuery, gql, useLazyQuery } from "@apollo/client";
import Card from "../components/Card";
import styled from "styled-components";
import Header from "../components/Header";

const Account = () => {
  const { data, loading } = useQuery(CURRENT_ACCOUNT);

  const [logOut] = useLazyQuery(LOG_OUT, {
    onCompleted: async () => {
      window.location.reload();
    },
  });

  if (loading) return null;

  const { firstName, lastName, email } = data.currentAccount;
  return (
    <div>
      <Header>Account</Header>
      <Card>
        <span>First name: {firstName}</span>
        <Divider />
        <span>Last name: {lastName}</span>
        <Divider /> <span>Emai: {email}</span>
        <Divider />
        <Button onClick={() => logOut()}>Log Out</Button>
      </Card>
    </div>
  );
};

const Button = styled.button`
  background-color: rgba(0, 0, 0, 0.6);
  border-radius: 8px;
  padding: 4px;
  color: white;
  outline: none;
  border: none;
  margin-top: 10px;
`;

const Divider = styled.div`
  height: 1px;
  margin: 3px 0;
  position: relative;
  width: 100%;
  background: radial-gradient(
    ellipse farthest-side at top center,
    white,
    transparent
  );
`;

const CURRENT_ACCOUNT = gql`
  query CurrentAccount {
    currentAccount {
      firstName
      lastName
      email
    }
  }
`;

const LOG_OUT = gql`
  query LogOut {
    logOut
  }
`;

export default Account;
