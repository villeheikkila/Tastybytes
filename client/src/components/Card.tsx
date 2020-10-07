import React, { FC } from "react";
import styled from "styled-components";

export const Card: FC = ({ children }) => {
  return <Container>{children}</Container>;
};

const Container = styled.div`
  display: flex;
  flex-direction: column;
  padding: 10px;
  width: 800px;
  border-radius: 8px;
  background-color: rgba(0, 0, 0, 0.4);

  @media (max-width: 800px) {
    width: calc(100vw - 28px);
  }
`;
