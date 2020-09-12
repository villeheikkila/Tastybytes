import styled from "styled-components";

const Input = styled.input<{ width?: string }>`
  background-color: inherit;
  color: rgba(255, 255, 255, 0.847);
  font-size: 38px;
  padding: 10px;
  border: none;
  outline: none;
  width: ${(props) => props.width || "100%"};
  height: 80px;
  margin-bottom: 10px;
`;

export default Input;
