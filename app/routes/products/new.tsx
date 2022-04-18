import { A } from "@mobily/ts-belt";
import React from "react";
import type { ActionFunction, LoaderFunction } from "remix";
import {
  Form,
  useActionData,
  useLoaderData,
  useSearchParams,
  useSubmit,
} from "remix";
import { getParams } from "remix-params-helper";
import { z } from "zod";
import { styled } from "~/stitches.config";
import { supabaseClient } from "~/supabase";

const CreateProductProps = z.object({
  company: z.string().optional(),
  category: z.string().optional(),
});

interface Category {
  id: number;
  name: string;
}

interface Subcategory {
  id: number;
  name: string;
  category_id: number;
  categories: Category;
}

interface Company {
  id: number;
  name: string;
}

interface Brand {
  id: number;
  name: string;
  companies: Company;
}

interface SubBrand {
  id: number;
  name: string;
  brand_id: number;
  brands: Brand;
}

interface Profile {
  id: string;
  username: string;
}

interface LoaderData {
  subcategories: Subcategory[];
  companies: Company[];
  subBrands: SubBrand[];
}
export const loader: LoaderFunction = async (): Promise<LoaderData> => {
  const subcategoriesQuery = supabaseClient
    .from("subcategories")
    .select("id, name, category_id, categories!inner(id, name)");

  const companiesQuery = supabaseClient.from("companies").select("id, name");

  const brandsQuery = supabaseClient
    .from("sub_brands")
    .select("id, name, brand_id, brands!inner(id, name, companies (id, name))");

  const [{ data: subcategories }, { data: companies }, { data: subBrands }] =
    await Promise.all([subcategoriesQuery, companiesQuery, brandsQuery]);

  return {
    subcategories: subcategories ?? [],
    companies: companies ?? [],
    subBrands: subBrands ?? [],
  };
};

interface ActionData {
  name: FormDataEntryValue | null;
}

export const action: ActionFunction = async ({ request, params }) => {};

const CreateProductSearchParams = z.object({
  categoryId: z.number().optional(),
  subcategoryId: z.number().optional(),
  companyId: z.number().optional(),
  brandId: z.number().optional(),
  subBrandId: z.number().optional(),
});

export default function Index() {
  const [searchParams] = useSearchParams();
  const submit = useSubmit();
  const { success, data: params } = getParams(
    searchParams,
    CreateProductSearchParams
  );

  if (!success) throw Error("Failed to parse search params!");

  const { subcategories, companies, subBrands } = useLoaderData<LoaderData>();

  const handleChange = (event: React.FormEvent<HTMLFormElement>) => {
    submit(event.currentTarget, { replace: true });
  };

  const categories = A.uniqBy(
    subcategories.flatMap((sb) => sb.categories),
    (c) => c.id
  );

  const brands = A.uniqBy(
    subBrands
      .filter((sb) => sb.brands.companies.id === params.companyId)
      .flatMap((sb) => sb.brands),
    (b) => b.id
  );

  console.log(subBrands.filter((sb) => sb.brand_id === params.brandId));

  const actionData = useActionData<ActionData>();
  console.log("actionData: ", actionData);

  return (
    <Root>
      <Header>
        <h1>Create new product</h1>

        <VerticalForm method="get" onChange={handleChange}>
          <Label>
            Category
            <select name="categoryId">
              {categories?.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </Label>
          {params.categoryId && (
            <Label>
              Subcategory
              <select name="subcategoryId">
                {subcategories
                  .filter(
                    ({ category_id }) => category_id === params.categoryId
                  )
                  .map((subcategory) => (
                    <option key={subcategory.id} value={subcategory.id}>
                      {subcategory.name}
                    </option>
                  ))}
              </select>
            </Label>
          )}
          {params.subcategoryId && (
            <Label>
              Company
              <select name="companyId">
                {A.sortBy(companies, (c) => c.name).map((company) => (
                  <option key={company.id} value={company.id}>
                    {company.name}
                  </option>
                ))}
              </select>
            </Label>
          )}

          {params.companyId && (
            <Label>
              Brand
              <select name="brandId">
                {brands?.map((brand) => (
                  <option key={brand.id} value={brand.id}>
                    {brand.name}
                  </option>
                ))}
              </select>
            </Label>
          )}

          {params.brandId && (
            <Label>
              Sub-brand
              <select name="subBrandId">
                {subBrands
                  .filter((sb) => sb.brand_id === params.brandId)
                  .map((brand) => (
                    <option key={brand.id} value={brand.id}>
                      {brand.name}
                    </option>
                  ))}
              </select>
            </Label>
          )}
        </VerticalForm>
        {params.companyId && (
          <form method="post">
            <input name="name" />
            <button type="submit">Create</button>
          </form>
        )}
      </Header>
    </Root>
  );
}

const Root = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
  justify: "center",
  alignItems: "center",
});

const Header = styled("header", {
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  gap: "10px",
});

export function ErrorBoundary({ error }: { error: Error }) {
  console.log("caught: ", error.message);

  return (
    <div>
      <h1>{JSON.stringify(error)}</h1>
    </div>
  );
}

const Label = styled("label", {
  display: "flex",
  width: "10rem",
});

const ErrorContainer = styled("div", {
  display: "flex",
  flexDirection: "column",
});

const VerticalForm = styled(Form, {
  display: "flex",
  flexDirection: "column",
  gap: "0.5rem",
  justifyContent: "flex-start",
});
