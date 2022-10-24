import React, { FC } from "react";
import styled from "styled-components";
import { motion } from "framer-motion";

export const Button: FC<{
  onClick?: () => void;
  disabled?: boolean;
  type?: "submit";
}> = ({ children, ...rest }) => (
  <MotionButton
    whileHover={{
      scale: 1,
      transition: { duration: 0.5 },
    }}
    whileTap={{ scale: 0.9 }}
    {...rest}
  >
    {children}
  </MotionButton>
);

const MotionButton = styled(motion.button)`
  width: 180px;
  height: 20px;
  background-color: ${(props) => props.theme.colors.blue};
  color: ${(props) => props.theme.colors.white};
  font-size: 20px;
  padding: 5px;
  border-radius: 8px;
  width: 250px;
  height: 60px;
  text-align: center;
`;
