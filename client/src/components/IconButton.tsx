import React from "react";
import { ButtonHTMLAttributes, FC } from "react";
import { Link } from "react-router-dom";
import styled from "styled-components";

export const IconButton: FC<
  { to?: any } & ButtonHTMLAttributes<HTMLButtonElement>
> = ({ to, children, ...rest }) => {
  return (
    <Button as={to ? Link : "button"} to={to} {...rest}>
      {children}
    </Button>
  );
};

const Button = styled.button<{ to: string }>`
  background-color: inherit;
  display: flex;
  place-items: center;
  outline: none;
  border: none;
`;
