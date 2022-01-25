import { Link, LoaderFunction, useLoaderData } from "remix";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { Layout } from "~/components/layout";
import { Typography } from "~/components/typography";
import { paths } from "~/utils/paths";

interface LoaderResult {
  data: SDK.SearchProductsQuery;
}

export const loader: LoaderFunction = async ({
  request,
  params,
}): Promise<LoaderResult> => {
  const url = new URL(request.url);
  const searchTerm = url.searchParams.get("term") ?? "";
  const data = await sdk().searchProducts({ searchTerm });
  return { data };
};

export default function Index() {
  const { data } = useLoaderData<LoaderResult>();

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>Search Products</Typography.H1>
      </Layout.Header>

      <Card.Container>
        {data?.searchProducts?.edges.map(({ node }) => (
          <Card.Wrapper key={node?.id}>
            <Link to={paths.company(node?.brand?.company?.id)}>
              <h2>{node?.brand?.company?.name ?? ""}</h2>
            </Link>
            <Link to={"/"}>
              <p>{node?.brand?.name}</p>
            </Link>
            <Link to={paths.products(node?.id)}>
              <p>{node?.name}</p>
            </Link>
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
}
