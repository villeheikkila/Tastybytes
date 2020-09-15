import React, { FC } from "react";
import styled from "styled-components";

const Heading: FC = ({ children }) => <H1>{children}</H1>;

const H1 = styled.h1`
  margin: 0;
  white-space: nowrap;
`;

export default Heading;
