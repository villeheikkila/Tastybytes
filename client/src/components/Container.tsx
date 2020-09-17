import styled from "styled-components";

const Container = styled.div<{
  y?: boolean;
  centered?: boolean;
  centeredParent?: boolean;
}>`
  display: flex;
  flex-direction: ${(props) => (props.y ? "column" : "row")};
  place-items: ${(props) => props.centered && "center"};

  ${(props) =>
    props.centeredParent &&
    `position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);`}
`;

export default Container;
