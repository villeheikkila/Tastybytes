import React, { useState, useEffect } from "react";
import { useCombobox } from "downshift";
import styled from "styled-components";
import { ReactComponent as DropdownIcon } from "../assets/candy.svg";

export interface Item {
  value: string;
  label: string;
}

const Combobox: React.FC<{
  items: Item[];
  setSelected: (item: Item | null) => void;
}> = ({ items, setSelected }) => {
  const [inputItems, setInputItems] = useState(items);

  const {
    isOpen,
    getToggleButtonProps,
    getMenuProps,
    getInputProps,
    getComboboxProps,
    highlightedIndex,
    getItemProps,
    selectedItem,
  } = useCombobox({
    items: inputItems,
    itemToString: (item) => item?.label || "",
    onInputValueChange: ({ inputValue }) => {
      setInputItems(
        items.filter(({ label }) =>
          label.toLowerCase().startsWith(inputValue?.toLowerCase() || "")
        )
      );
    },
  });

  useEffect(() => {
    setSelected(selectedItem);
  }, [selectedItem]);

  return (
    <Container>
      <InputContainer {...getComboboxProps()}>
        <Input {...getInputProps()} placeholder="Company" />
        <Button
          type="button"
          {...getToggleButtonProps()}
          aria-label="toggle menu"
        >
          <DropdownIcon fill="#fff" />
        </Button>
      </InputContainer>

      <Menu {...getMenuProps()}>
        {isOpen &&
          inputItems.map((item, index) => (
            <MenuItem
              selected={highlightedIndex === index}
              key={`${item.value}${index}`}
              {...getItemProps({ item, index })}
            >
              {item.label}
            </MenuItem>
          ))}
      </Menu>
    </Container>
  );
};

const Button = styled.button`
  background: none;
  border: 0;
  outline: none;
  padding: 0;
  width: 24px;
`;

const Container = styled.div``;

const Menu = styled.ul`
  border-radius: 8px;
  background-color: rgba(0, 0, 0, 0.4);
  position: absolute;
  z-index: 100;
  width: 600px;
  padding: 10px;
`;

const MenuItem = styled.li<{ selected: boolean }>`
  list-style-type: none;
  background-color: ${(props) => (props.selected ? "red" : "")};
  border-radius: 8px;
`;

const InputContainer = styled.div`
  background-color: rgba(85, 85, 85, 0.8);
  border-radius: 8px;
  display: block;
  border: 1px solid transparent;
  color: rgba(255, 255, 255, 0.847);
  outline: none;
  padding: 5px;
`;

const Input = styled.input`
  background: none;
  border: 0;
  padding: 0;
  outline: none;
  color: rgba(255, 255, 255, 0.847);
  width: calc(100% - 32px);

  &:focus {
    border-color: rgba(255, 255, 255, 0.247);
  }
`;

export default Combobox;
