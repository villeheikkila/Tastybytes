import { LoaderFunction, useLoaderData } from "remix";
import SDK, { sdk } from "~/api.server";
import { styled } from "~/stitches.config";

export const loader: LoaderFunction = async ({
  request,
  params,
}): Promise<SDK.GetProductByIdQuery> => {
  if (!params.productId) {
    throw new Response("What a joke! Not found.", { status: 404 });
  }

  const productId = parseInt(params.productId, 10);
  console.log("productId: ", productId);
  const companies = await sdk().getProductById({ productId });
  return companies;
};

export default function Index() {
  const data = useLoaderData<SDK.GetProductByIdQuery>();

  return (
    <div style={{ fontFamily: "system-ui, sans-serif", lineHeight: "1.4" }}>
      {data.product.name}
    </div>
  );
}

const H1 = styled("h1", { fontWeight: "bold", color: "$red" });
