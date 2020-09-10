import React from "react";
import Header from "../components/Header";
import Card from "../components/Card";
import styled from "styled-components";

const Home = () => {
  const checkIns = ["1", "2", "3"];
  return (
    <div>
      <Header>Home</Header>
      <CardContainer>
        {checkIns.map((e) => (
          <Card>{e}</Card>
        ))}
      </CardContainer>
    </div>
  );
};

const CardContainer = styled.div`
  display: grid;
  grid-gap: 15px;
`;
export default Home;
