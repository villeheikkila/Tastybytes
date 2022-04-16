import { Container, Table } from "@nextui-org/react";
import { GetServerSideProps } from "next";
import React from "react";
import { Stars } from "../../../components/Stars";
import { supabase } from "../../../utils/initSupabase";

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

const cols = [
  "category",
  "subcategory",
  "manufacturer",
  "brandOwner",
  "productName",
  "rating",
] as const;

type ColKey = typeof cols[number];

const columns: { name: string; uid: ColKey }[] = [
  { name: "Category", uid: "category" },
  { name: "Subcategory", uid: "subcategory" },
  { name: "Manufacturer", uid: "manufacturer" },
  { name: "Brand Owner", uid: "brandOwner" },
  { name: "Product", uid: "productName" },
  { name: "Rating", uid: "rating" },
];

type Columns = typeof columns[number];

const addSpace = (s: string | null) => {
  return s === null ? "" : `${s} `;
};

export default function CheckInTable({ data }: { data: any }) {
  if (!data) return null;

  const renderCell = (tastedRow: TastedRow, columnKey: ColKey) => {
    switch (columnKey) {
      case "rating": {
        const cellValue = tastedRow["rating"];
        if (!cellValue) return;
        const rating = Math.floor(cellValue / 2);
        return (
          <div>
            <Stars rating={rating} />
          </div>
        );
      }
      default:
        return tastedRow[columnKey];
    }
  };

  const mapToTastedRow = (row: Response): TastedRow => ({
    id: row.id,
    category: row.products.subcategories.categories.name,
    subcategory: row.products.subcategories.name,
    manufacturer: row.products.companies.name,
    brandOwner: row.products.sub_brands.brands.companies.name,
    productName: `${addSpace(row.products.sub_brands.brands.name)}${addSpace(
      row.products.sub_brands.name
    )}${addSpace(row.products.name)}${addSpace(row.products.description)}`,
    rating: row.rating,
  });

  const mappedRows = data.map(mapToTastedRow);

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
              {(column: Columns) => (
                <Table.Column key={String(column.uid)} align={"start"}>
                  {column.name}
                </Table.Column>
              )}
            </Table.Header>
            <Table.Body items={mappedRows}>
              {(item: TastedRow) => (
                <Table.Row>
                  {(columnKey: ColKey) => (
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
  productName: string;
  rating: number | null;
};

export const getServerSideProps: GetServerSideProps = async ({
  req,
  params,
}) => {
  const { user } = await supabase.auth.api.getUserByCookie(req);

  if (!user || !params?.slug) {
    return { props: {}, redirect: { destination: "/", permanent: false } };
  } else {
    console.log(params.slug);
    const { data, error } = await supabase
      .from("check_ins")
      .select(
        `id, rating, review, products (id, name, description, companies (id, name), sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))), profiles!inner(username)`
      )
      .eq("profiles.username", String(params.slug))
      .limit(2500);

    if (error) {
      console.log("error: ", error);
    }
    console.log("data: ", data);

    return { props: { data } };
  }
};
