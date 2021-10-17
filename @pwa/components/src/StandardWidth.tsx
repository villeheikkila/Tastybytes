import React, { FC } from "react";

import { styled } from "@pwa/common";

export interface StandardWidthProps {
  children: React.ReactNode;
}

export const StandardWidth: FC<StandardWidthProps> = ({ children }) => (
  <Wrapper>{children}</Wrapper>
);

const Wrapper = styled("div", {
  padding: "1rem",
  maxWidth: "min(95vw, 36rem)",
});
