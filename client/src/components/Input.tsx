import styled from "styled-components";

const Input = styled.input<{ error?: boolean }>`
  width: 70%;
  height: 30px;
  outline: none;
  border: none;
  height: 20px;
  background-color: #333;
  color: rgba(255, 255, 255, 1);
  font-size: 16px;
  height: 40px;
  padding: 0px 16px;
  border-radius: 8px;
  font-weight: 600;

  ::placeholder {
    color: #999;
    font-size: 12px;
  }

  ${(props) => props.error && "box-shadow: inset 0 0 0 1px #f36;"}
`;

export default Input;
