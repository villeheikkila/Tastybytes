import { Link, LoaderFunction, useLoaderData } from "remix";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { Layout } from "~/components/layout";
import { Stars } from "~/components/stars";
import { Typography } from "~/components/typography";
import { paths } from "~/utils/paths";

export const loader: LoaderFunction = async ({
  request,
  params,
}): Promise<SDK.GetProductByIdQuery> => {
  if (!params.productId) {
    throw new Response("Not found.", { status: 404 });
  }

  const productId = parseInt(params.productId, 10);
  const companies = await sdk().getProductById({ productId });
  return companies;
};

export default function Index() {
  const { product } = useLoaderData<SDK.GetProductByIdQuery>();

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>
          {product?.brand?.company?.name} {product?.brand?.name} {product?.name}
        </Typography.H1>
      </Layout.Header>

      <Card.Container>
        {product?.checkIns.nodes.map(({ id, author, rating }) => (
          <Card.Wrapper key={id}>
            <p>
              <Link to={paths.user(author.username)}>
                <b>{author.username}</b>
              </Link>{" "}
              has tasted{" "}
              <Link
                to={paths.products(id)}
              >{`${product?.brand?.name} - ${product?.name}`}</Link>{" "}
              by{" "}
              <Link to={paths.company(product?.brand?.company.id)}>
                {product?.brand?.company?.name}
              </Link>
            </p>
            {rating && <Stars rating={rating} />}
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
}
