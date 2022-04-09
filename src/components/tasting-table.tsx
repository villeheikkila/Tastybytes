import { Col, Row, Table, Tooltip } from "@nextui-org/react";
import React from "react";
import { IconButton } from "./icon-button";
import { DeleteIcon } from "./icons/delete-icon";
import { EditIcon } from "./icons/edit-icon";

export type TastedRow = {
  id: number;
  category: string;
  manufacturer: string;
  brandOwner: string;
  brand: string;
  subBrand: string;
  flavour: string;
  description: string;
  rating: number | null;
  review: string;
};

export default function TastedTable({ rows }: { rows: TastedRow[] }) {
  const columns = [
    { name: "Category", uid: "category" },
    { name: "Manufacturer", uid: "manufacturer" },
    { name: "Brand Owner", uid: "brand_owner" },
    { name: "Brand", uid: "brand" },
    { name: "Sub-brand", uid: "sub-brand" },
    { name: "Flavour", uid: "flavour" },
    { name: "Description", uid: "description" },
    { name: "Rating", uid: "rating" },
    { name: "Review", uid: "review" },
  ];

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
  return (
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
      <Table.Body items={rows}>
        {(item: TastedRow) => (
          <Table.Row>
            {(columnKey) => (
              <Table.Cell>{renderCell(item, columnKey)}</Table.Cell>
            )}
          </Table.Row>
        )}
      </Table.Body>
    </Table>
  );
}
