import styled from "styled-components";
import { theme } from "../common";

export const ErrorText = styled.strong<{ isError?: boolean }>`
  ${theme.typography.body}
  color: ${(props) => props.theme.colors.red};
  display: ${({ isError }) => (isError && isError ? "block" : "hidden")};
`;
