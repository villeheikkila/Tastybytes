import styled from "styled-components";

const HeaderInput = styled.input<{ width?: string }>`
  background-color: inherit;
  color: ${(props) => props.theme.colors.white};
  font-size: 38px;
  padding: 10px;
  border: none;
  outline: none;
  width: ${(props) => props.width || "100%"};
  height: 80px;
  margin-bottom: 10px;
`;

export default HeaderInput;
