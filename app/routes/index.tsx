import { Form, LoaderFunction, useLoaderData } from "remix";
import SDK, { sdk } from "~/api.server";
import { styled } from "~/stitches.config";
import { getUserId } from "~/utils/session.server";

export const loader: LoaderFunction = async ({request}): Promise<SDK.GetCompaniesQuery> => {
  const userId = await getUserId(request)
  console.log('userId: ', userId);
  const companies = await sdk().getCompanies();
  return companies;
};

export default function Index() {
  const data = useLoaderData<SDK.GetCompaniesQuery>();

  return (
    <div style={{ fontFamily: "system-ui, sans-serif", lineHeight: "1.4" }}>
      <H1>Tasted</H1>
      <Form action="/logout" method="post">
                <button type="submit" className="button">
                  Logout
                </button>
      </Form>
      {data.companies.nodes.map(company => <p>{company.name}</p>)}
    </div>
  );
}

const H1 = styled('h1', {fontWeight: "bold", color: "$red"})
