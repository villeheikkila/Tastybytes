import { Link, LoaderFunction, useLoaderData } from "remix";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { Layout } from "~/components/layout";
import { Stars } from "~/components/stars";
import { Typography } from "~/components/typography";
import { getDisplayName } from "~/utils";
import { paths } from "~/utils/paths";

export const loader: LoaderFunction = async ({
  params,
}): Promise<SDK.GetProfilePageByUsernameQuery> => {
  if (!params.username) {
    throw new Response("Not found.", { status: 404 });
  }

  const companies = await sdk().getProfilePageByUsername({
    username: params.username,
  });
  return companies;
};

export default function Index() {
  const { userByUsername: user } =
    useLoaderData<SDK.GetProfilePageByUsernameQuery>();

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>{user && getDisplayName(user)}</Typography.H1>
      </Layout.Header>
      <Card.Container>
        {user?.authoredCheckIns.nodes.map(({ id, product, rating }) => (
          <Card.Wrapper key={id}>
            <p>
              <b>{getDisplayName(user)}</b> has tasted{" "}
              <Link
                to={paths.products(product.id)}
              >{`${product?.brand?.name} - ${product?.name}`}</Link>{" "}
              by{" "}
              <Link to={paths.company(product.brand.company.id)}>
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
