import { json } from "@remix-run/node";
import {
  Form,
  Outlet,
  useActionData,
  useCatch,
  useLoaderData,
  useTransition,
} from "@remix-run/react";
import type { ActionFunction, LoaderFunction } from "remix";
import { getParams, getFormData } from "remix-params-helper";
import { z } from "zod";
import { Stars } from "~/components/stars";
import { supabaseClient } from "~/supabase";
import { authenticator, sessionStorage, supabaseStrategy } from "~/auth.server";

export function headers() {
  return {
    "Cache-Control": "max-age=3600, s-maxage=4200",
  };
}

interface Category {
  id: number;
  name: string;
}

interface Subcategory {
  id: number;
  name: string;
  categories: Category;
}

interface BrandOwner {
  id: number;
  name: string;
}

interface Brand {
  id: number;
  name: string;
  companies: BrandOwner;
}

interface SubBrand {
  id: number;
  name: string;
  brands: Brand;
}

interface Product {
  id: number;
  name: string;
  sub_brands: SubBrand;
  subcategory: Subcategory;
}

interface Profile {
  id: string;
  username: string;
}

interface CheckIn {
  id: number;
  rating: number | null;
  review: string | null;
  profiles: Profile;
}

type LoaderData = { product: Product; checkIns: CheckIn[] | null };

const ParamsSchema = z.object({
  category: z.string(),
  subcategory: z.string(),
  brandOwner: z.string(),
  brand: z.string(),
  sub_brand: z.string(),
  product: z.string(),
});

const CheckInFormSchema = z.object({
  review: z.string().optional(),
  rating: z.string().optional(),
  productId: z.number(),
});

export const action: ActionFunction = async ({ request }) => {
  const session = await sessionStorage.getSession(
    request.headers.get("Cookie")
  );

  const authorId = session.data["sb:session"].user.id;

  const { success, data: checkInForm } = await getFormData(
    request,
    CheckInFormSchema
  );
  if (success && authorId) {
    console.log(checkInForm);

    const { data, error } = await supabaseClient.from("check_ins").insert({
      author_id: authorId,
      product_id: checkInForm.productId,
      rating: checkInForm.rating,
      review: checkInForm.review,
    });
    console.log("error: ", error);

    console.log("data: ", data);
  }

  return null;
};

const findProduct = async (filter: {
  product: string;
  brand: string;
  sub_brand: string;
  brandOwner: string;
  subcategory: string;
  category: string;
}): Promise<Product> => {
  const queryBuilder = supabaseClient
    .from("products")
    .select(
      "id, name, subcategories!inner(id, name, categories!inner(id, name)), sub_brands!inner(id, name, brands!inner(id, name, companies!inner(id, name)))"
    )
    .eq("name", filter.product)
    .eq("sub_brands.brands.name", filter.brand)
    .eq("sub_brands.brands.companies.name", filter.brandOwner)
    .eq("subcategories.name", filter.subcategory)
    .eq("subcategories.categories.name", filter.category);

  if (filter.sub_brand === "null") {
    queryBuilder.is("sub_brands.name", null);
  } else {
    queryBuilder.eq("sub_brands.name", filter.sub_brand);
  }

  const response = await queryBuilder.single();

  if (response.error) {
    console.error(response.error);
  }

  return response.data;
};

export const loader: LoaderFunction = async ({ request, params }) => {
  const { success, data: decodedParams } = getParams(params, ParamsSchema);
  if (success) {
    const product = await findProduct(decodedParams);

    if (product === null) {
      throw Error("No product found!");
    }

    const { data: checkIns } = await supabaseClient
      .from("check_ins")
      .select("rating, review, product_id, profiles (id, username)")
      .eq("product_id", product.id);

    return json<LoaderData>({ product, checkIns });
  }
};

export default function Screen() {
  const { checkIns, product } = useLoaderData<LoaderData>();
  // const actionData = useActionData();
  const transition = useTransition();

  return (
    <>
      <h1>
        {product.sub_brands.brands.companies.name}
        {product.sub_brands.brands.name} {product.sub_brands.name}
        {product.name}
      </h1>

      <div>
        Add check-in!
        <Form method="post">
          <label>
            Review
            <input name="review" type="text" />
          </label>
          <label>
            Rating
            <input name="rating" type="number" />
          </label>
          <input
            type="hidden"
            id="productId"
            name="productId"
            value={product.id}
          />
          <button type="submit">
            {transition.submission ? "Saving..." : "Save"}
          </button>
        </Form>
      </div>
      <Outlet />

      {checkIns?.map((checkIn) => (
        <div key={checkIn.id}>
          {checkIn.profiles.username} <Stars rating={checkIn.rating ?? 0} />
        </div>
      ))}
    </>
  );
}

export function CatchBoundary() {
  const caught = useCatch();

  return (
    <div>
      <h1>
        {caught.status} {caught.statusText}
      </h1>
    </div>
  );
}

export function ErrorBoundary({ error }: { error: Error }) {
  return (
    <div>
      <pre>{error.message}</pre>
    </div>
  );
}
