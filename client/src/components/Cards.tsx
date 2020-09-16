import React from "react";
import styled from "styled-components";
import { useTransform, useMotionValue, motion } from "framer-motion";
import useDimensions from "../hooks/useDimensions";

const Cards = ({ data, children }: { data: any[]; children: JSX.Element }) => {
  const scrollY = useMotionValue(0);
  const { height: windowHeight, width: windowWidth } = useDimensions();
  const scale = useTransform(scrollY, [0, 100], [0, 1]);
  const opacity = useTransform(scrollY, [0, 100], [0, 1]);

  // Calculate the height of the CardContainer and the width of the Cards
  const draggableHeight = windowHeight - 150;
  const width = windowWidth > 800 ? 800 : windowWidth * 0.9;
  const height = 200;
  const padding = 20;

  return (
    <>
      <RefreshIndicator
        style={{
          scale: scale,
          opacity: opacity,
        }}
      />
      <CardContainer
        width={width}
        height={draggableHeight}
        whileTap={{ cursor: "grabbing" }}
      >
        <motion.div
          style={{
            width: 800,
            height: draggableHeight,
            y: scrollY,
          }}
          drag="y"
          dragConstraints={{
            top: -draggableHeight + 100,
            bottom: 0,
          }}
        >
          {data.map((props: any, index: any) => (
            <Card
              width={width}
              height={height}
              top={(height + padding) * index}
              key={index}
            >
              {React.cloneElement(children, { ...props })}
            </Card>
          ))}
        </motion.div>
      </CardContainer>
    </>
  );
};

const CardContainer = styled(motion.div)<{ height: number; width: number }>`
  width: ${(props) => `${props.width}px`};
  height: ${(props) => `${props.height}px`};
  border-radius: 10;
  overflow: hidden;
  position: relative;
  transform: translateZ(0);
  cursor: grab;
`;

const Card = styled(motion.div)<{
  top?: number;
  width: number;
  height: number;
}>`
  border-radius: 8px;
  position: absolute;
  background-color: rgba(0, 0, 0, 0.4);
  width: ${(props) => `${props.width}px`};
  height: ${(props) => `${props.height}px`};
  padding: 10px;
  top: ${(props) => `${props.top}px`};
  display: grid;
  grid-template-areas: "header" "score" "content";
  grid-template-rows: 1fr 1fr 5fr;
`;

const RefreshIndicator = styled(motion.div)`
  width: 40px;
  height: 40px;
  border-radius: 20px;
  background-color: #333;
  position: absolute;
  top: 100;
  left: 50%;
`;

export default Cards;
