import React, { useCallback } from "react";
import styled from "styled-components";
import { useSpring, useMotionValue, motion } from "framer-motion";

const Sheet: React.FC<{ onClose: () => void }> = ({ children, onClose }) => {
  const dragConstraints = React.useRef<HTMLDivElement>(null);
  const windowHeight = window.innerHeight;
  const drag = useMotionValue(0);
  const spring = useSpring(windowHeight, {
    stiffness: 300,
    damping: 30,
    mass: 0.2,
  });
  const onDrag = useCallback((_, { point }) => spring.set(point.y), [spring]);

  const onDragEnd = useCallback(
    (_, { velocity }) => {
      if (velocity.y > 500) {
        onClose();
      } else {
        spring.stop();
        spring.set(32);
      }

      drag.set(0);
    },
    [spring, drag, onClose]
  );

  return (
    <Container
      key="sheet"
      ref={dragConstraints}
      initial={{ y: windowHeight }}
      animate={{ y: 32, transition: { type: "tween" } }}
      exit={{ y: windowHeight }}
      style={{ y: spring }}
    >
      <DragHandler />

      <DragArea
        style={{ y: drag }}
        drag="y"
        dragElastic={0}
        dragConstraints={dragConstraints}
        dragMomentum={false}
        onDrag={onDrag}
        onDragEnd={onDragEnd}
      />
      <Content>{children}</Content>
    </Container>
  );
};

const Container = styled(motion.div)`
  position: absolute;
  top: 0;
  bottom: 0;
  border-top-right-radius: 8px;
  border-top-left-radius: 8px;
  background-color: ${(props) => props.theme.colors.primary};
  box-shadow: 0px -2px 16px rgba(0, 0, 0, 0.3);
  display: flex;
  flex-direction: column;
  width: 800px;

  @media (max-width: 800px) {
    width: 100vw;
  }

  @media (min-width: 1000px) {
    border-bottom-right-radius: 8px;
    border-bottom-left-radius: 8px;
    max-height: 800px;
  }
`;

const Content = styled.div`
  position: absolute;
  width: 100%;
  top: 48px;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 1;
  overflow: auto;
`;

const DragArea = styled(motion.div)`
  position: absolute;
  height: 48px;
  top: 0;
  left: 0;
  right: 0;
`;

const DragHandler = styled.div`
  height: 32px;
  width: 100%;
  position: relative;

  &::before {
    content: "";
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    width: 80px;
    height: 5px;
    border-radius: 99px;
    background-color: rgba(255, 255, 255, 0.847);
  }
`;

export default Sheet;
