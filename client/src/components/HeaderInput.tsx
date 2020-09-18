import styled from "styled-components";

const HeaderInput = styled.input<{ width?: string }>`
  background-color: inherit;
  color: ${(props) => props.theme.colors.white};
  font-size: 1.5rem;
  padding: 10px;
  border: none;
  outline: none;
  width: ${(props) => props.width || "100%"};
  height: 80px;
`;

export default HeaderInput;
