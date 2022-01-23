import { Link, LoaderFunction, useLoaderData } from "remix";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { Layout } from "~/components/layout";
import { Stars } from "~/components/stars";
import { Typography } from "~/components/typography";
import { paths } from "~/utils/paths";

export const loader: LoaderFunction =
  async (): Promise<SDK.GetActivityFeedQuery> => {
    const companies = await sdk().getActivityFeed();
    return companies;
  };

export default function Index() {
  const data = useLoaderData<SDK.GetActivityFeedQuery>();

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>Activity Feed</Typography.H1>
      </Layout.Header>
      <Card.Container>
        {data.checkIns.nodes.map(({ id, product, rating, author }) => (
          <Card.Wrapper key={id}>
            <p>
              <Link to={paths.user(author?.username ?? "")}>
                {author.username}
              </Link>{" "}
              has tasted{" "}
              <Link
                to={paths.products(product?.id)}
              >{`${product?.brand?.name} - ${product?.name}`}</Link>{" "}
              by{" "}
              <Link to={`/company/${product?.brand?.company?.name}`}>
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
