import { Col, Container, Row, Table, Tooltip } from "@nextui-org/react";
import React, { useEffect, useState } from "react";
import { IconButton } from "../components/icon-button";
import { DeleteIcon } from "../components/icons/delete-icon";
import { EditIcon } from "../components/icons/edit-icon";
import { useSupabaseClient } from "../hooks/useSupabase";

interface Response {
  id: number;
  rating: number;
  review: string;
  products: {
    id: number;
    name: string;
    description: string;
    companies: {
      id: number;
      name: string;
    };
    subcategories: {
      id: number;
      name: string;
      categories: {
        id: number;
        name: string;
      };
    };
    sub_brands: {
      id: number;
      name: string;
      brands: {
        id: number;
        name: string;
        companies: {
          id: number;
          name: string;
        };
      };
    };
  };
}
export default function CheckInTable() {
  const client = useSupabaseClient();

  const [data, setData] = useState<Response[]>();
  console.log("data: ", data);

  useEffect(() => {
    const fe = async () => {
      const { data, error } = await client
        .from("check_ins")
        .select(
          `id, rating, review, products (id, name, description, companies (id, name), sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name)))`
        )
        .limit(2500);
      console.log("data: ", data);
      setData(data as unknown as Response[]);
    };
    fe();
  }, []);

  if (!data) return null;

  const renderCell = (tastedRow: TastedRow, columnKey: React.Key) => {
    const cellValue = tastedRow[columnKey];
    switch (columnKey) {
      case "rating":
        return cellValue ? cellValue / 2 : "-";
      case "actions":
        return (
          <Row justify="center" align="center">
            <Col css={{ d: "flex" }}>
              <Tooltip content="Details">
                <IconButton
                  onClick={() => console.log("View user", tastedRow?.id)}
                >
                  <EditIcon size={20} fill="#979797" />
                </IconButton>
              </Tooltip>
            </Col>
            <Col css={{ d: "flex" }}>
              <Tooltip content="Edit user">
                <IconButton
                  onClick={() => console.log("Edit user", tastedRow?.id)}
                >
                  <EditIcon size={20} fill="#979797" />
                </IconButton>
              </Tooltip>
            </Col>
            <Col css={{ d: "flex" }}>
              <Tooltip
                content="Delete user"
                color="error"
                onClick={() => console.log("Delete user", tastedRow?.id)}
              >
                <IconButton>
                  <DeleteIcon size={20} fill="#FF0080" />
                </IconButton>
              </Tooltip>
            </Col>
          </Row>
        );
      default:
        return cellValue;
    }
  };

  const columns = [
    { name: "Category", uid: "category" },
    { name: "Subcategory", uid: "subcategory" },
    { name: "Manufacturer", uid: "manufacturer" },
    { name: "Brand Owner", uid: "brandOwner" },
    { name: "Brand", uid: "brand" },
    { name: "Sub-brand", uid: "subBrand" },
    { name: "Flavour", uid: "flavour" },
    { name: "Description", uid: "description" },
    { name: "Rating", uid: "rating" },
    { name: "Review", uid: "review" },
  ];

  const mapToTastedRow = (row: Response): TastedRow => ({
    id: row.id,
    category: row.products.subcategories.categories.name,
    subcategory: row.products.subcategories.name,
    manufacturer: row.products.companies.name,
    brandOwner: row.products.sub_brands.brands.companies.name,
    brand: row.products.sub_brands.brands.name,
    subBrand: row.products.sub_brands.name,
    flavour: row.products.name,
    description: row.products.description,
    rating: row.rating,
    review: row.review,
  });

  const mappedRows = data.map(mapToTastedRow);
  console.log("mappedRows: ", mappedRows);

  return (
    <div>
      <Container fluid>
        {mappedRows && (
          <Table
            aria-label="Example table with custom cells"
            css={{
              height: "auto",
              minWidth: "100%",
            }}
            selectionMode="none"
          >
            <Table.Header columns={columns}>
              {(column) => (
                <Table.Column
                  key={column.uid}
                  hideHeader={column.uid === "actions"}
                  align={column.uid === "actions" ? "center" : "start"}
                >
                  {column.name}
                </Table.Column>
              )}
            </Table.Header>
            <Table.Body items={mappedRows}>
              {(item: TastedRow) => (
                <Table.Row>
                  {(columnKey) => (
                    <Table.Cell>{renderCell(item, columnKey)}</Table.Cell>
                  )}
                </Table.Row>
              )}
            </Table.Body>
          </Table>
        )}
      </Container>
    </div>
  );
}

export type TastedRow = {
  id: number;
  category: string;
  subcategory: string;
  manufacturer: string;
  brandOwner: string;
  brand: string;
  subBrand: string;
  flavour: string;
  description: string;
  rating: number | null;
  review: string;
};
