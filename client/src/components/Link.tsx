import React, { FC } from "react";
import { Link as RouterLink } from "react-router-dom";
import styled from "styled-components";

const Link: FC<{ to: string }> = ({ children, to }) => (
  <StyledLink to={to}>{children}</StyledLink>
);

const StyledLink = styled(RouterLink)`
  font-family: ${(props) => props.theme.typography.body.fontFamily};
  font-size: ${(props) =>
    props.theme.typography.fontSizes[props.theme.typography.body.size]};
  font-weight: ${(props) => props.theme.typography.link.fontWeight};
  color: ${(props) => props.theme.typography.link.color};
  line-height: ${(props) => props.theme.typography.body.fontHeight};
`;

export default Link;
