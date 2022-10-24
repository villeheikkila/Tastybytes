import styled from "styled-components";

export const Spacer = styled.div<{
  x?: boolean;
  y?: boolean;
  amount?: number;
}>`
  width: ${(props) => (props.x ? `${props.amount}px` : 0)};
  height: ${(props) => (props.y ? `${props.amount}px` : 0)};
`;
