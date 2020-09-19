import React, { useState } from "react";
import styled from "styled-components";
import { useQuery } from "@apollo/client";
import { SubcategoriesByCategory } from "../../../generated/SubcategoriesByCategory";
import CreateSubcategoryForm from "./CreateSubcategory";
import HeaderInput from "../../../components/HeaderInput";
import IconButton from "../../../components/IconButton";
import Container from "../../../components/Container";
import SelectionButton from "../../../components/SelectionButton";
import { SUBCATEGORIES } from "../graphql";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlusCircle } from "@fortawesome/free-solid-svg-icons";
import theme from "../../../theme";

const SubcategoryPicker: React.FC<{
  setSelected: (value: any) => void;
  selected: any;
}> = ({ setSelected, selected }) => {
  const [value, setValue] = useState("");
  const [show, setShow] = useState(false);
  const { data, loading } = useQuery<SubcategoriesByCategory>(SUBCATEGORIES, {
    variables: { categoryId: selected.category.id },
  });

  if (loading || !data) return null;

  const filteredCompanies = data.subcategoriesByCategory.filter(
    ({ name }: any) => new RegExp(value, "ig").test(name)
  );

  return (
    <Content>
      <Container>
        <HeaderInput
          placeholder="Search Subcategories..."
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

      {show && <CreateSubcategoryForm categoryId={selected.category.id} />}

      {filteredCompanies.map((item: any) => (
        <SelectionButton
          key={`search-companies-${item.id}`}
          onClick={() => setSelected({ ...selected, subcategory: item })}
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

export default SubcategoryPicker;
