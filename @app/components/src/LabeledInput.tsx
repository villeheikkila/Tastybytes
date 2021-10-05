import { blackA } from "@radix-ui/colors";
import * as LabelPrimitive from "@radix-ui/react-label";
import { styled } from "@stitches/react";
import React from "react";

const StyledLabel = styled(LabelPrimitive.Root, {
  fontSize: 15,
  fontWeight: 500,
  color: "white",
  userSelect: "none",
});

const Label = StyledLabel;

const Flex = styled("div", {
  display: "flex",
  padding: "0 20px",
  flexWrap: "wrap",
  alignItems: "center",
});

const Input = styled("input", {
  all: "unset",
  width: 200,
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  borderRadius: 4,
  padding: "0 10px",
  height: 35,
  fontSize: 15,
  lineHeight: 1,
  marginLeft: "15px",
  color: "white",
  backgroundColor: blackA.blackA5,
  boxShadow: `0 0 0 1px ${blackA.blackA9}`,
  "&:focus": { boxShadow: `0 0 0 2px black` },
});

interface LabeledInputProps extends React.ComponentProps<typeof Input> {
  label: string;
}

const spacesToHyphens = (s: string) => s.replaceAll(" ", "-");

export const LabeledInput = React.forwardRef<
  React.ElementRef<typeof Input>,
  LabeledInputProps
>(function labeledInput({ label }, forwardedRef) {
  const id = spacesToHyphens(label);
  return (
    <Flex>
      <Label htmlFor={id}>{label}</Label>
      <Input ref={forwardedRef} type="text" id={id} />
    </Flex>
  );
});
