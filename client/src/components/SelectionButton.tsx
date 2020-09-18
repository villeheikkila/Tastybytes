import styled from "styled-components";

const SelectionButton = styled.button`
  background-color: inherit;
  color: inherit;
  border-left: none;
  border-right: none;
  outline: none;
  padding: 12px;
  border-top: solid 1px rgba(255, 255, 255, 0.247);
  border-bottom: solid 1px rgba(255, 255, 255, 0.247);

  :hover,
  :focus {
    background-color: rgba(0, 0, 0, 0.4);
  }
`;

export default SelectionButton;
