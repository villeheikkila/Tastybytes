import { blackA, tomato, whiteA } from "@radix-ui/colors";
import * as AvatarPrimitive from "@radix-ui/react-avatar";
import { styled } from "./stitches.config";
import React from "react";

const StyledAvatar = styled(AvatarPrimitive.Root, {
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  verticalAlign: "middle",
  overflow: "hidden",
  userSelect: "none",
  width: 45,
  height: 45,
  borderRadius: "100%",
  backgroundColor: blackA.blackA3,
  variants: {
    status: {
      warn: {
        "::after": {
          display: "block",
          content: " ",
          width: "12px",
          height: "12px",
          borderRadius: "50%",
          position: "absolute",
          backgroundColor: tomato.tomato10,
          right: "0px",
          top: "12px",
          boxShadow: "20px 20px 60px #161616 -20px -20px 60px #ffffff",
        },
      },
    },
  },
});

type StyledAvatarProps = React.ComponentProps<typeof StyledAvatar>;

const StyledImage = styled(AvatarPrimitive.Image, {
  width: "100%",
  height: "100%",
  objectFit: "cover",
  borderRadius: "inherit",
});

const StyledFallback = styled(AvatarPrimitive.Fallback, {
  width: "100%",
  height: "100%",
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  backgroundColor: "green",
  color: whiteA.whiteA12,
  fontSize: "0.8rem",
  textTransform: "uppercase",
  fontWeight: "bold",
});

interface AvatarProps {
  name: string;
  imageUrl?: string | null;
  status?: StyledAvatarProps["status"];
}

const shortenName = (name: string) => name.substring(0, 2);

export const Avatar: React.FC<AvatarProps> = ({ imageUrl, name, status }) => (
  <StyledAvatar status={status}>
    {imageUrl ? (
      <StyledImage src={imageUrl} alt={`Avatar of ${name}`} />
    ) : (
      <StyledFallback>{shortenName(name)}</StyledFallback>
    )}
  </StyledAvatar>
);
