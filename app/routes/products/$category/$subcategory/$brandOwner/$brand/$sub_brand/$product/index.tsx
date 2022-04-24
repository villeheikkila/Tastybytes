import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { json } from "@remix-run/node";
import {
  Form,
  Outlet,
  useCatch,
  useLoaderData,
  useTransition,
} from "@remix-run/react";
import { useState } from "react";
import { getFormData, getParams } from "remix-params-helper";
import { z } from "zod";
import { authenticator } from "~/auth.server";
import { Avatar } from "~/components/avatar";
import { Card } from "~/components/card";
import { Input, Textarea } from "~/components/input";
import { Star, Stars } from "~/components/stars";
import { Button } from "~/routes/login";
import { styled } from "~/stitches.config";
import { supabaseClient } from "~/supabase";
import type { Profile } from "~/types/custom";
import { paths } from "~/utils";
import { Configs } from "~/utils/configs";

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

interface CheckIn {
  id: number;
  rating: number | null;
  review: string | null;
  profiles: Profile;
}

type LoaderData = {
  product: Product;
  checkIns: CheckIn[] | null;
  isAuthenticated: boolean;
  supabaseUrl: string;
};

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
  const session = await authenticator.isAuthenticated(request);
  if (!session?.user) throw Error("User is not logged in!");

  const {
    success,
    data: checkInForm,
    errors,
  } = await getFormData(request, CheckInFormSchema);

  if (success) {
    supabaseClient.auth.setAuth(session.access_token);
    const { error } = await supabaseClient.from("check_ins").insert({
      author_id: session.user.id,
      product_id: checkInForm.productId,
      rating: checkInForm.rating,
      review: checkInForm.review,
    });

    return json({ errors: error });
  }

  return json({ errors: errors });
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
      .select("rating, review, product_id, profiles (id, username, avatar_url)")
      .eq("product_id", product.id);

    const user = await authenticator.isAuthenticated(request);

    return json<LoaderData>({
      product,
      checkIns,
      isAuthenticated: !!user,
      supabaseUrl: Configs.supabaseUrl,
    });
  }
};

export default function Screen() {
  const { checkIns, product, isAuthenticated, supabaseUrl } =
    useLoaderData<LoaderData>();
  // const actionData = useActionData();
  const transition = useTransition();
  console.log("checkIns: ", checkIns);

  const [stars, setStars] = useState<number | undefined>(); // replace with CSS

  return (
    <Container>
      <Card.Container>
        <h1>
          {product.sub_brands.brands.companies.name}
          {product.sub_brands.brands.name} {product.sub_brands.name}
          {product.name}
        </h1>
      </Card.Container>

      {isAuthenticated && (
        <Card.Container>
          <CheckInForm method="post">
            <H2>Add check-in!</H2>

            <Textarea name="review" placeholder="Review" />
            <div>
              {Array.from({ length: 5 }, (_, i) => (
                <label
                  id={(i + 1).toString()}
                  onClick={() => setStars(i + 1)}
                  key={i}
                >
                  <input
                    type="radio"
                    name="rating"
                    id={(i + 1).toString()}
                    value={i + 1}
                  />
                  <Star
                    type={stars && stars >= i + 1 ? "filled" : "empty"}
                    key={i}
                  />
                </label>
              ))}
            </div>
            <input
              type="hidden"
              id="productId"
              name="productId"
              value={product.id}
            />
            <div>
              <Button type="submit">
                {transition.submission ? "Saving..." : "Check-in!"}
              </Button>
            </div>
          </CheckInForm>
        </Card.Container>
      )}

      <Outlet />

      {checkIns?.map((checkIn) => (
        <Card.Container key={checkIn.id}>
          <Avatar
            name={checkIn.profiles.username}
            status={undefined}
            imageUrl={paths.avatarUrl({
              profilePic: checkIn.profiles.avatar_url,
              supabaseUrl,
            })}
          />
          {checkIn.profiles.username ?? checkIn.profiles.id}{" "}
          <Stars rating={checkIn.rating ?? 0} />
        </Card.Container>
      ))}
    </Container>
  );
}

const H2 = styled("h2", { fontSize: "1.2rem" });
const CheckInForm = styled(Form, {
  display: "flex",
  flexDirection: "column",
  gap: "0.5rem",
});

const Container = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "1rem",
});

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
