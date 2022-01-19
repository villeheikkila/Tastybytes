import { useLoaderData } from "remix";
import { sdk } from "~/api";
import { GetCompaniesQuery } from "~/generated/client.generated";

export const loader = async (): Promise<GetCompaniesQuery> => {
  const companies = await sdk().getCompanies();
  return companies;
};

export default function Index() {
  const data = useLoaderData<GetCompaniesQuery>();
  console.log('data: ', data);

  return (
    <div style={{ fontFamily: "system-ui, sans-serif", lineHeight: "1.4" }}>
      <h1>Welcome to Remix</h1>
    </div>
  );
}
