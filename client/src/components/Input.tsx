import styled from "styled-components";

const Input = styled.input`
  background-color: rgba(85, 85, 85, 0.8);
  border-radius: 8px;
  display: block;
  width: 100%;
  border: 1px solid transparent;
  color: rgba(255, 255, 255, 0.847);
  outline: none;
  padding: 5px;

  &::placeholder {
    color: rgba(255, 255, 255, 0.247);
  }

  &:focus {
    border-color: rgba(255, 255, 255, 0.247);
  }
`;

export default Input;
