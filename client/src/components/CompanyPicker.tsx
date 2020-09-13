import React, { useState } from "react";
import styled from "styled-components";
import { gql, useQuery } from "@apollo/client";
import { ReactComponent as DropdownIcon } from "../assets/plus.svg";
import CreateCompany from "./CreateCompany";
import { Companies } from "../generated/Companies";

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
    <Container>
      <FlexWrapper>
        <HeaderInput
          placeholder="Search Companies..."
          name="name"
          value={value}
          onChange={({ target }) => setValue(target.value)}
        />
        <Button onClick={() => setShow(!show)}>
          <DropdownIcon width="48px" fill="rgba(255, 255, 255, 0.247)" />
        </Button>
      </FlexWrapper>

      {show && <CreateCompany />}

      {filteredCompanies.map((item: Item, i) => (
        <Selection
          key={`search-companies-${i}`}
          onClick={() => setSelected({ ...selected, company: item })}
        >
          {item.label}
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

const QUERY_COMPANIES = gql`
  query Companies {
    companies {
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

export default CompanyPicker;
