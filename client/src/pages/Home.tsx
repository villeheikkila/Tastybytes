import React, { useEffect, useRef, useState } from "react";
import Header from "../components/Header";
import { gql, useQuery } from "@apollo/client";
import styled from "styled-components";
import { Reviews } from "../generated/Reviews";
import Spinner from "../components/Spinner";
import Text from "../components/Text";
import {
  useTransform,
  useMotionValue,
  motion,
  motionValue,
  useViewportScroll,
} from "framer-motion";
import useDimensions from "../hooks/useDimensions";

const Home = () => {
  const { data, loading } = useQuery<Reviews>(GET_REVIEWS);
  const scrollY = useMotionValue(0);
  const { height: windowHeight, width: windowWidth } = useDimensions();
  const scale = useTransform(scrollY, [0, 100], [0, 1]);
  const opacity = useTransform(scrollY, [0, 100], [0, 1]);
  if (loading || !data) return <Spinner />;
  // Calculate the height of the CardContainer and the width of the Cards
  const draggableHeight = windowHeight - 150;
  const width = windowWidth > 800 ? 800 : windowWidth * 0.9;
  const height = 200;
  const padding = 20;

  return (
    <div>
      <Header>Home</Header>
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
        >
          {data.reviews.map(({ id, score, review, treat }: any, index) => (
            <Card
              width={width}
              height={height}
              top={(height + padding) * index}
              key={index}
            >
              <CardHeader>
                <Text>{treat.name}</Text> <Text>{treat.company.name}</Text>
                <Text>{treat.category.name}</Text>
                {treat.subcategory.name}
              </CardHeader>
              <CardScore>{score}</CardScore> <CardContent>{review}</CardContent>
            </Card>
          ))}
        </motion.div>
      </CardContainer>
    </div>
  );
};

const CardContainer = styled(motion.div)<{ height: number; width: number }>`
  width: ${(props) => `${props.width}px`};
  height: ${(props) => `${props.height}px`};
  border-radius: 10;
  position: relative;
  transform: translateZ(0);
  overflow-y: scroll;
  ::-webkit-scrollbar {
    width: 0;
  }
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

const CardHeader = styled.div`
  grid-area: "header";
  font-size: 24px;
  font-weight: 600;
  display: grid;
  grid-auto-flow: column;
  height: 20px;
  grid-template-columns: 1fr 1fr 0.5fr 0.5fr;
`;

const CardScore = styled.div`
  grid-area: "score";
`;

const CardContent = styled.div`
  grid-area: "content";
`;

const GET_REVIEWS = gql`
  query Reviews {
    reviews {
      id
      review
      score
      treat {
        name
        category {
          name
        }
        subcategory {
          name
        }
        company {
          name
        }
      }
    }
  }
`;

export default Home;
