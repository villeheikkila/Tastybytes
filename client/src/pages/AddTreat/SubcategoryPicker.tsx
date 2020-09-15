import React, { useState } from "react";
import styled from "styled-components";
import { gql, useQuery } from "@apollo/client";
import { ReactComponent as DropdownIcon } from "../../assets/plus.svg";
import { SubcategoriesByCategory } from "../../generated/SubcategoriesByCategory";
import CreateSubcategoryForm from "./CreateSubcategory";

const SubcategoryPicker: React.FC<{
  setSelected: (value: any) => void;
  selected: any;
}> = ({ setSelected, selected }) => {
  const { data, loading } = useQuery<SubcategoriesByCategory>(SUBCATEGORIES, {
    variables: { categoryId: selected.category.id },
  });
  console.log("data: ", data);

  const [value, setValue] = useState("");
  const [show, setShow] = useState(false);

  if (loading || !data) return null;

  const filteredCompanies = data.subcategoriesByCategory.filter(
    ({ name }: any) => new RegExp(value, "ig").test(name)
  );

  return (
    <Container>
      <FlexWrapper>
        <HeaderInput
          placeholder="Search Subcategories..."
          name="name"
          value={value}
          onChange={({ target }) => setValue(target.value)}
        />
        <Button onClick={() => setShow(!show)}>
          <DropdownIcon width="48px" fill="rgba(255, 255, 255, 0.247)" />
        </Button>
      </FlexWrapper>

      {show && <CreateSubcategoryForm categoryId={selected.category.id} />}

      {filteredCompanies.map((item: any) => (
        <Selection
          key={`search-companies-${item.id}`}
          onClick={() => setSelected({ ...selected, subcategory: item })}
        >
          {item.name}
        </Selection>
      ))}
    </Container>
  );
};

const FlexWrapper = styled.div`
  display: flex;
`;

const Button = styled.button`
  background-color: inherit;
  outline: none;
  border: none;
`;

const Selection = styled.button`
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

const HeaderInput = styled.input`
  background-color: inherit;
  color: rgba(255, 255, 255, 0.847);
  font-size: 38px;
  padding: 10px;
  border: none;
  outline: none;
  width: 100%;
  height: 80px;
  margin-bottom: 10px;
`;

const SUBCATEGORIES = gql`
  query SubcategoriesByCategory($categoryId: ID!) {
    subcategoriesByCategory(categoryId: $categoryId) {
      id
      name
    }
  }
`;

const Container = styled.div`
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
