import React, { FC } from "react";
import styled from "styled-components";

const Text: FC = ({ children }) => <P>{children}</P>;

const P = styled.p`
  margin: 0;
`;

export default Text;
