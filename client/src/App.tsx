import React from "react";
import styled from "styled-components";
import { useQuery, gql } from "@apollo/client";

export interface Package {
  alternatives: number[] | null;
  dependencies: number[];
  description: string | null;
  id: number;
  name: string;
  tags: number[];
}

const ACCOUNTS = gql`
  query {
    accounts {
      firstName
      lastName
      email
    }
  }
`;

const App = () => {
  const { data, loading } = useQuery(ACCOUNTS);
  console.log("loading: ", loading);
  console.log("data: ", data);
  return (
    <>
      <Header>
        <Heading>HerQ</Heading>
        <Stats></Stats>
      </Header>

      <Page></Page>
    </>
  );
};

const Page = styled.div`
  padding: 2rem 2vw;
`;

const Header = styled.header`
  display: flex;
  justify-content: center;
  align-items: center;
  flex-direction: column;
`;

const Heading = styled.h1`
  text-align: center;
  vertical-align: middle;
  font-size: 48px;
  margin: 0;
  padding: 20px;
`;

const Stats = styled.div`
  display: flex;
  flex-direction: column;
  height: 30px;
  margin-top: 10px;

  > p {
    margin: 0;
  }
`;

export default App;
