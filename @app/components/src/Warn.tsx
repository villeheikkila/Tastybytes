import { redA } from "@radix-ui/colors";
import { styled } from "@stitches/react";
import React from "react";

export interface WarnProps extends React.ComponentProps<typeof DotContainer> {
  children: React.ReactNode;
  okay?: boolean;
}

const Dot = styled("div", {
  display: "absolute",
  height: "8px",
  width: "8px",
  left: 0,
  borderRadius: "50%",
  backgroundColor: redA.redA10,
});

const DotContainer = styled("div");

export function Warn({ children, okay, ...props }: WarnProps) {
  console.log("okay: ", okay);
  return okay ? (
    <>{children}</>
  ) : (
    <span>
      <DotContainer {...props}>
        {children} <Dot />
      </DotContainer>
    </span>
  );
}
