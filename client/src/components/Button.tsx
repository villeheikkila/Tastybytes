import React from "react";
import styled from "styled-components";
import { motion, ForwardRefComponent, HTMLMotionProps } from "framer-motion";

const Button: React.FC<{ onClick?: () => void }> = ({ children, onClick }) => (
  <MotionButton
    whileHover={{
      scale: 1,
      transition: { duration: 0.5 },
    }}
    whileTap={{ scale: 0.9 }}
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

export default Button;
