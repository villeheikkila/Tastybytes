import { useLoaderData } from "remix";
import { sdk } from "~/api.server";
import { GetCompaniesQuery } from "~/generated/client.generated";
import { styled } from "~/stitches.config";

export const loader = async (): Promise<GetCompaniesQuery> => {
  const companies = await sdk().getCompanies();
  return companies;
};

export default function Index() {
  const data = useLoaderData<GetCompaniesQuery>();
  console.log('data: ', data);

  return (
    <div style={{ fontFamily: "system-ui, sans-serif", lineHeight: "1.4" }}>
      <H1>Tasted</H1>
      {data.companies.nodes.map(company => <p>{company.name}</p>)}
    </div>
  );
}

const H1 = styled('h1', {fontWeight: "bold", color: "$red"})
