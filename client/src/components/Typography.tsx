import React, { FC } from "react";
import styled from "styled-components";
import { theme } from "../common";

export const Typography: FC = ({ children }) => <P>{children}</P>;

const P = styled.p`
  ${theme.typography.body};
`;
