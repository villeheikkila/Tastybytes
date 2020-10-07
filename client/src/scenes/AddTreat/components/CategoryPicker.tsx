import { faPlusCircle } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import React, { FC, useState } from "react";
import styled from "styled-components";
import { CreateCategoryForm } from ".";
import { theme } from "../../../common";
import {
  Container,
  HeaderInput,
  IconButton,
  SelectionButton,
} from "../../../components";
import { useCategoriesQuery } from "../queries.hooks";

export const CategoryPicker: FC<{
  setSelected: (value: any) => void;
  selected: any;
}> = ({ setSelected, selected }) => {
  const [value, setValue] = useState("");
  const [show, setShow] = useState(false);
  const { data, loading } = useCategoriesQuery();

  if (loading || !data) return null;

  const filteredCompanies = data.categories.filter(({ name }: any) =>
    new RegExp(value, "ig").test(name)
  );

  return (
    <Content>
      <Container>
        <HeaderInput
          placeholder="Search Categories..."
          name="name"
          value={value}
          onChange={({ target }) => setValue(target.value)}
        />
        <IconButton onClick={() => setShow(!show)}>
          <FontAwesomeIcon
            icon={faPlusCircle}
            size="lg"
            color={theme.colors.darkGray}
          />
        </IconButton>
      </Container>

      {show && <CreateCategoryForm />}

      {filteredCompanies.map((item: any) => (
        <SelectionButton
          key={`search-companies-${item.id}`}
          onClick={() => setSelected({ ...selected, category: item })}
        >
          {item.name}
        </SelectionButton>
      ))}
    </Content>
  );
};

const Content = styled.div`
  display: flex;
  flex-direction: column;
  padding: 10px;
  font-size: 28px;
  border-radius: 8px;

  @media (max-width: 800px) {
    width: calc(100vw);
  }
`;
