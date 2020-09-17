import React, { FC } from "react";
import styled from "styled-components";

const Text: FC = ({ children }) => <P>{children}</P>;

const P = styled.h1`
  margin: 0;
  font-size: 24px;
  white-space: nowrap;
  font-family: ${(props) => props.theme.typography.body.fontFamily};
  font-size: ${(props) =>
    props.theme.typography.fontSizes[props.theme.typography.body.size]};
  font-weight: ${(props) => props.theme.typography.body.fontWeight};
  color: "rgba(255, 255, 255, 1.0)";
  line-height: ${(props) => props.theme.typography.body.fontHeight};
`;

export default Text;
