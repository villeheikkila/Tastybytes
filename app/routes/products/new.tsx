import { StatusCodes } from "http-status-codes";
import React from "react";
import {
  ActionFunction,
  Form,
  Link,
  LoaderFunction,
  Outlet,
  redirect,
  useActionData,
  useLoaderData,
  useSearchParams,
  useSubmit,
  useTransition,
} from "remix";
import { z } from "zod";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { ErrorMessage } from "~/components/error-message";
import Input from "~/components/input";
import { Layout } from "~/components/layout";
import { Stars } from "~/components/stars";
import { Typography } from "~/components/typography";
import { styled } from "~/stitches.config";
import Codecs from "~/utils/codecs";
import FormUtils from "~/utils/form-utils";
import { paths } from "~/utils/paths";
import { getUserId } from "~/utils/session.server";

interface LoaderResult {
  categories: SDK.GetCreateItemPropsQuery["categories"];
  companies: SDK.GetCreateItemPropsQuery["companies"];
  types: any;
  brands: any;
}

export const loader: LoaderFunction = async ({
  request,
  params,
}): Promise<LoaderResult> => {
  const data = await sdk().getCreateItemProps();
  const url = new URL(request.url);
  const category = url.searchParams.get("category") ?? "";
  const type = url.searchParams.get("type") ?? "";
  const company = url.searchParams.get("company") ?? "";

  console.log("company: ", company);

  const types = data.categories?.nodes?.find((c) => c?.name === category)
    ?.typesByCategory.nodes;

  const brands = data.companies?.nodes?.find((e) => e.id.toString() === company)
    ?.brands.nodes;

  console.log("brands: ", brands);

  return {
    categories: data.categories,
    companies: data.companies,
    types,
    brands,
  };
};

const CheckInForm = z.object({
  review: Codecs.review,
  rating: Codecs.rating,
});

type SafeParseError = z.SafeParseReturnType<
  typeof CheckInForm,
  { review?: string; rating?: number }
>;

interface ActionData {
  name: FormDataEntryValue | null;
}

export const action: ActionFunction = async ({ request, params }) => {
  const url = new URL(request.url);
  const type = url.searchParams.get("type") ?? "";
  const company = url.searchParams.get("company") ?? "";
  const brand = url.searchParams.get("brand") ?? "";

  const formData = await request.formData();
  const name = formData.get("name");

  const p = await sdk().createProduct({
    typeId: parseInt(type, 10),
    brandId: parseInt(brand, 10),
    manufacturerId: parseInt(company, 10),
    name,
  });
  console.log("name: ", name);

  return redirect(paths.products(p?.createProduct?.product?.id));
};

export default function Index() {
  const [searchParams] = useSearchParams();
  console.log("searchParams: ", searchParams);
  const { categories, companies, types, brands } =
    useLoaderData<LoaderResult>();
  const submit = useSubmit();

  function handleChange(event: any) {
    submit(event.currentTarget, { replace: true });
  }

  const category = searchParams.get("category");
  const type = searchParams.get("type");

  const company = searchParams.get("company");

  console.log("category: ", category);

  const actionData = useActionData<ActionData>();
  console.log("actionData: ", actionData);

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>Create new product</Typography.H1>

        <VerticalForm method="get" onChange={handleChange}>
          <Label>
            Select Category
            <select name="category">
              {categories?.nodes.map((category) => (
                <option key={category.name} value={category.name}>
                  {category.name}
                </option>
              ))}
            </select>
          </Label>
          {category && (
            <Label>
              Select Type
              <select name="type">
                {types?.map((type) => (
                  <option key={type.id} value={type.id}>
                    {type.name}
                  </option>
                ))}
              </select>
            </Label>
          )}
          {type && (
            <Label>
              Select Company
              <select name="company">
                {companies?.nodes.map((company) => (
                  <option key={company.id} value={company.id}>
                    {company.name}
                  </option>
                ))}
              </select>
            </Label>
          )}
          {company && (
            <Label>
              Select Company
              <select name="brand">
                {brands?.map((brand) => (
                  <option key={brand.id} value={brand.id}>
                    {brand.name}
                  </option>
                ))}
              </select>
            </Label>
          )}
        </VerticalForm>
        <form method="post">
          <Input name="name" />
          <button type="submit">Create</button>
        </form>
      </Layout.Header>
    </Layout.Root>
  );
}

const Label = styled("label", {
  display: "flex",
  flexDirection: "column",
  width: "10rem",
});

const Errors = ({
  name,
  safeParseError,
}: {
  name: keyof z.infer<typeof CheckInForm>;
  safeParseError?: SafeParseError;
}) => {
  if (!safeParseError || safeParseError.success) return null;

  const errors = safeParseError.error.issues.filter(({ path }) =>
    path.includes(name)
  );

  return (
    <ErrorContainer>
      {errors.map((error) => (
        <ErrorMessage key={error.message}>{error.message}</ErrorMessage>
      ))}
    </ErrorContainer>
  );
};

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
