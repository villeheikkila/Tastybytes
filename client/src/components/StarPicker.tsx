import React, { FC } from "react";
import Container from "./Container";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faStar } from "@fortawesome/free-solid-svg-icons";
import styled from "styled-components";

const StarPicker: FC<{ score: number; setScore?: (score: number) => void }> = ({
  score,
  setScore,
}) => {
  return (
    <Container>
      {[1, 2, 3, 4, 5].map((number) => (
        <button
          onClick={(event) => {
            event.preventDefault();
            if (setScore) setScore(number);
          }}
        >
          <Star icon={faStar} isActive={score >= number} index={number} />
        </button>
      ))}
    </Container>
  );
};

const Star = styled(FontAwesomeIcon)<{ isActive: boolean; index: number }>`
  color: ${(props) => props.isActive && props.theme.colors.yellow};
  transition: all ${(props) => `0.${props.index + 5}s`} ease;

  :hover,
  :focus {
    color: ${(props) =>
      props.isActive ? props.theme.colors.white : props.theme.colors.yellow};
  }
`;

export default StarPicker;
