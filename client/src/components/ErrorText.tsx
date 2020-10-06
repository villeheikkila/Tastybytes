import styled from "styled-components";
import { theme } from "../common";

export const ErrorText = styled.strong`
  ${theme.typography.body}
  color: ${(props) => props.theme.colors.red}
`;
