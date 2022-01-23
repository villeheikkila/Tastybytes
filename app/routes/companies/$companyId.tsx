import { Link, LoaderFunction, useLoaderData } from "remix";
import SDK, { sdk } from "~/api.server";
import { Card } from "~/components/card";
import { Layout } from "~/components/layout";
import { Stars } from "~/components/stars";
import { Typography } from "~/components/typography";
import { styled } from "~/stitches.config";
import { paths } from "~/utils/paths";

export const loader: LoaderFunction = async ({
  params,
}): Promise<SDK.GetCompanyByIdQuery> => {
  console.log("params.companyId: ", params.companyId);

  if (!params.companyId) {
    throw new Response("Not found.", { status: 404 });
  }

  const companyId = parseInt(params.companyId, 10);
  const companies = await sdk().getCompanyById({ companyId });
  return companies;
};

export default function Index() {
  const { company } = useLoaderData<SDK.GetCompanyByIdQuery>();

  return (
    <Layout.Root>
      <Layout.Header>
        <Typography.H1>{company.name}</Typography.H1>
      </Layout.Header>
      <Card.Container>
        {company.brands.edges.map((brand) => (
          <Card.Wrapper key={brand.node.id}>
            <h3>{brand.node.name}</h3>
            {brand.node.products.edges.map((product) => (
              <div key={product.node.id}>
                <Link to={paths.products(product.node.id)}>
                  {product.node.name}
                </Link>
              </div>
            ))}
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
}

const H1 = styled("h1", { fontWeight: "bold", color: "$red" });
