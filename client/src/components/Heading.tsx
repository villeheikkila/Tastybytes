import React, { FC } from "react";
import styled from "styled-components";
import { theme } from "../common";

type HeadingTags = "h1" | "h2" | "h3" | "h4";

export const Heading: FC<{ tag?: HeadingTags }> = ({
  children,
  tag = "h1",
}) => <H1 as={tag}>{children}</H1>;

const H1 = styled.h1`
  ${theme.typography.heading}
  margin: 0;
  font-size: 24px;
  white-space: nowrap;
`;
