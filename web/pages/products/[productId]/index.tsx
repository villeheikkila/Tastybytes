import { supabaseServerClient } from "@supabase/auth-helpers-nextjs";
import { BlockTitle } from "konsta/react";
import { GetServerSideProps } from "next";
import { API } from "../../../api";
import { FetchCheckInsResult } from "../../../api/check-ins";
import { ProductJoined } from "../../../api/products";
import { CheckInsFeed } from "../../../components/check-in-feed";
import Layout from "../../../components/layout";
import { constructProductName } from "../../../utils";

interface UserProfile {
  product: ProductJoined;
  initialCheckIns: FetchCheckInsResult[];
}

const UserProfile = ({ product, initialCheckIns }: UserProfile) => {
  return (
    <Layout title={constructProductName(product)}>
      <BlockTitle>{product.name}</BlockTitle>

      <CheckInsFeed
        fetcher={API.checkIns.createFetchByProductId(product.id)}
        initialCheckIns={initialCheckIns}
      />
    </Layout>
  );
};

export const getServerSideProps: GetServerSideProps = async (ctx) => {
  const client = supabaseServerClient(ctx);
  const productId = parseInt(String(ctx.params!.productId), 10);

  const [product, initialCheckIns] = await Promise.all([
    API.products.getById(productId),
    API.checkIns.createFetchByProductId(productId)(0, client),
  ]);

  return {
    props: {
      product,
      initialCheckIns,
    },
  };
};

export default UserProfile;
