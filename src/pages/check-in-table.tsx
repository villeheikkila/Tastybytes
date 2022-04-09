import { Col, Container, Row, Table, Tooltip } from "@nextui-org/react";
import React, { useEffect } from "react";
import { CheckInNodeFragment, useGetCheckInsQuery } from "../generated/graphql";
import { IconButton } from "../components/icon-button";
import { DeleteIcon } from "../components/icons/delete-icon";
import { EditIcon } from "../components/icons/edit-icon";
import { useInView } from "react-intersection-observer";

export default function CheckInTable() {
  const { ref, inView } = useInView();

  const { loading, data, fetchMore } = useGetCheckInsQuery({
    variables: { username: "villeheikkila" },
    fetchPolicy: "cache-and-network",
  });

  const profile = data?.profilesCollection?.edges[0]?.node;

  const fetchMoreRows = async (endCursor: string | undefined) => {
    const res = await fetchMore({
      variables: {
        username: "villeheikkila",
        afterCursor: endCursor,
      },
    });

    console.log("res: ", res);
  };

  useEffect(() => {
    const pageInfo = profile?.check_insCollection?.pageInfo;
    console.log("pageInfo: ", pageInfo);

    if (pageInfo?.hasNextPage) {
      fetchMoreRows(pageInfo.endCursor);
    }
  }, [inView]);

  if (loading) {
    return <div>Loading...</div>;
  }

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

  const mapToTastedRow = (row: CheckInNodeFragment): TastedRow => ({
    id: row.id,
    category: row.products?.subcategories?.categories?.name ?? "",
    manufacturer: row.products?.companies?.name ?? "",
    brandOwner: row.products?.sub_brands?.brands?.companies?.name ?? "",
    brand: row.products?.sub_brands?.brands?.name ?? "",
    subBrand: row.products?.sub_brands?.name ?? "",
    flavour: row.products?.name ?? "",
    description: row.products?.description ?? "",
    rating: row.rating ?? null,
    review: row.review ?? "",
  });

  console.log("length", profile?.check_insCollection);
  const mappedRows = profile?.check_insCollection?.edges.flatMap(({ node }) =>
    node ? mapToTastedRow(node) : []
  );

  return (
    <div>
      <Container fluid>
        <Row>{profile?.username}</Row>
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
        <div ref={ref} />
      </Container>
    </div>
  );
}

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
