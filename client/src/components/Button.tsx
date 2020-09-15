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
  background-color: #0af;
  color: rgba(255, 255, 255, 0.847);
  font-size: 20px;
  padding: 5px;
  border: none;
  border-radius: 8px;
  width: 250px;
  outline: none;
  height: 60px;
`;

export default Button;
