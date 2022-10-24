import React, { FC } from "react";
import { Link as RouterLink } from "react-router-dom";
import styled from "styled-components";
import { theme } from "../common";

export const Link: FC<{ to: string }> = ({ children, to }) => (
  <StyledLink to={to}>{children}</StyledLink>
);

const StyledLink = styled(RouterLink)`
  ${theme.typography.body}
  ${theme.typography.link}
`;
