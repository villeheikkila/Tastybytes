import React, { FC } from "react";
import styled from "styled-components";

type HeadingTags = "h1" | "h2" | "h3" | "h4";

const Heading: FC<{ tag?: HeadingTags }> = ({ children, tag = "h1" }) => (
  <H1 as={tag}>{children}</H1>
);

const H1 = styled.h1`
  margin: 0;
  font-size: 24px;
  white-space: nowrap;
  font-family: ${(props) => props.theme.typography.heading.fontFamily};
  font-size: ${(props) =>
    props.theme.typography.fontSizes[props.theme.typography.heading.size]};
  font-weight: ${(props) => props.theme.typography.heading.fontWeight};
  color: "rgba(255, 255, 255, 1.0)";
  line-height: ${(props) => props.theme.typography.heading.fontHeight};
`;

export default Heading;
