import React, { useState } from "react";
import styled from "styled-components";
import { useQuery } from "@apollo/client";
import { ReactComponent as DropdownIcon } from "../../../assets/plus.svg";
import CreateCompany from "./CreateCompany";
import { Companies } from "../../../generated/Companies";
import HeaderInput from "../../../components/HeaderInput";
import theme from "../../../theme";
import IconButton from "../../../components/IconButton";
import Container from "../../../components/Container";
import SelectionButton from "../../../components/SelectionButton";
import { QUERY_COMPANIES } from "../graphql";

export interface Item {
  value: string;
  label: string;
}

const CompanyPicker: React.FC<{
  setSelected: (value: any) => void;
  selected: any;
}> = ({ setSelected, selected }) => {
  const { data } = useQuery<Companies>(QUERY_COMPANIES);

  const [value, setValue] = useState("");
  const [show, setShow] = useState(false);

  const companies =
    data?.companies.map(({ id, name }) => ({
      value: id,
      label: name,
    })) || [];

  const filteredCompanies = companies.filter(({ label }) =>
    new RegExp(value, "ig").test(label)
  );

  return (
    <Content>
      <Container>
        <HeaderInput
          placeholder="Search Companies..."
          name="name"
          value={value}
          onChange={({ target }) => setValue(target.value)}
        />
        <IconButton onClick={() => setShow(!show)}>
          <DropdownIcon width="48px" fill={theme.colors.darkGray} />
        </IconButton>
      </Container>

      {show && <CreateCompany />}

      {filteredCompanies.map((item: Item, i) => (
        <SelectionButton
          key={`search-companies-${i}`}
          onClick={() => setSelected({ ...selected, company: item })}
        >
          {item.label}
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

export default CompanyPicker;
