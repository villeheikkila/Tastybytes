import React, { FC } from "react";
import styled from "styled-components";
import theme from "../theme";

const Text: FC = ({ children }) => <P>{children}</P>;

const P = styled.p`
  ${theme.typography.body};
`;

export default Text;
