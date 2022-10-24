import { motion, useMotionValue, useTransform } from "framer-motion";
import React, { ReactElement } from "react";
import styled from "styled-components";
import { useDimensions } from "../common";

interface IProps<T> {
  data: T[];
  component: (data: T, index: number) => ReactElement;
  reduceHeight: number;
  onDragEnd?: any;
}

export function Cards<T extends object>({
  data,
  component,
  reduceHeight,
  onDragEnd,
}: IProps<T>) {
  const { height: windowHeight, width: windowWidth } = useDimensions();
  const scrollY = useMotionValue(0);
  const scale = useTransform(scrollY, [0, 100], [0, 1]);
  const opacity = useTransform(scrollY, [0, 100], [0, 1]);

  // Calculate the height of the CardContainer and the width of the Cards
  const draggableHeight = windowHeight - reduceHeight;
  const width = windowWidth > 800 ? 800 : windowWidth;
  const height = 200;
  const padding = 20;

  const Component = component;

  return (
    <>
      <RefreshIndicator
        style={{
          scale,
          opacity,
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
          onDragEnd={onDragEnd}
        >
          {data.map((e, i) => (
            <Card
              width={width}
              height={height}
              top={(height + padding) * i}
              key={i}
            >
              <Component {...e} />
            </Card>
          ))}
        </motion.div>
      </CardContainer>
    </>
  );
}

const CardContainer = styled(motion.div)<{ height: number; width: number }>`
  width: ${(props) => `${props.width}px`};
  height: ${(props) => `${props.height}px`};
  border-radius: 10;
  position: relative;
  transform: translateZ(0);
  cursor: grab;

  overflow-y: scroll;
  ::-webkit-scrollbar {
    width: 0;
  }
`;

const Card = styled(motion.div)<{
  top?: number;
  width: number;
  height: number;
}>`
  border-radius: 8px;
  position: absolute;
  background-color: ${(props) => props.theme.colors.primary};
  width: ${(props) => `${props.width}px`};
  height: ${(props) => `${props.height}px`};
  padding: 10px;
  top: ${(props) => `${props.top}px`};
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
