import React, { useState } from "react";
import styled from "styled-components";
import { useQuery } from "@apollo/client";
import { Categories } from "../../../generated/Categories";
import CreateCategoryForm from "./CreateCategory";
import HeaderInput from "../../../components/HeaderInput";
import Container from "../../../components/Container";
import IconButton from "../../../components/IconButton";
import SelectionButton from "../../../components/SelectionButton";
import { CATEGORIES } from "../graphql";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlusCircle } from "@fortawesome/free-solid-svg-icons";
import theme from "../../../theme";

const CategoryPicker: React.FC<{
  setSelected: (value: any) => void;
  selected: any;
}> = ({ setSelected, selected }) => {
  const [value, setValue] = useState("");
  const [show, setShow] = useState(false);
  const { data, loading } = useQuery<Categories>(CATEGORIES);

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

export default CategoryPicker;
