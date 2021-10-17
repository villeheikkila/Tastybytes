import { redA } from "@radix-ui/colors";
import { styled } from "./stitches.config";
import React from "react";

export interface WarnProps extends React.ComponentProps<typeof DotContainer> {
  children: React.ReactNode;
  okay?: boolean;
}

const Dot = styled("span", {
  height: "8px",
  width: "8px",
  borderRadius: "50%",
  backgroundColor: redA.redA10,
});

const DotContainer = styled("div");

export const Warn = ({ children, okay }: WarnProps) => {
  return okay ? (
    <>{children}</>
  ) : (
    <>
      {children} <Dot />
    </>
  );
};
